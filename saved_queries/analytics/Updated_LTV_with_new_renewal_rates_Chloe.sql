

-- TABLE SCHEMA
DROP TABLE test.test_segmented_ltv;

CREATE TABLE IF NOT EXISTS test.test_segmented_ltv (
    country VARCHAR ENCODE ZSTD,
    market VARCHAR ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR(50) ENCODE ZSTD,
    is_in_intro_offer_period BOOLEAN ENCODE ZSTD,
    retention_curve BIGINT ENCODE ZSTD,
    sample_weight BIGINT ENCODE ZSTD,
    renewal_rate DOUBLE PRECISION ENCODE ZSTD,
    renewal_periods BIGINT ENCODE ZSTD,
    gross_price DOUBLE PRECISION ENCODE ZSTD,
    gross_full_price DOUBLE PRECISION ENCODE ZSTD,
    predicted_rate DOUBLE PRECISION ENCODE ZSTD,
    revenue DOUBLE PRECISION ENCODE ZSTD,
    year_n BIGINT ENCODE ZSTD,
    net_revenue DOUBLE PRECISION ENCODE ZSTD,
    ltv DOUBLE PRECISION ENCODE ZSTD,
    created_execution_date TIMESTAMP WITH TIME ZONE ENCODE ZSTD
);

DELETE FROM test.test_segmented_ltv
WHERE created_execution_date = '{{ ts }}';

INSERT INTO test.test_segmented_ltv (
    country,
    market,
    subscription_duration,
    platform,
    is_in_intro_offer_period,
    retention_curve,
    sample_weight,
    renewal_rate,
    renewal_periods,
    gross_price,
    gross_full_price,
    predicted_rate,
    revenue,
    year_n,
    net_revenue,
    ltv,
    created_execution_date
)
(
WITH
    offsets AS (
    SELECT ROW_NUMBER() OVER () - 1 AS months_into_lifecycle
    FROM der.subscriptions_events
    LIMIT 36
    ),

    sub_duration AS (
    SELECT DISTINCT subscription_duration, platform, is_in_intro_offer_period
    FROM der.subscriptions_events
    WHERE subscription_duration IS NOT NULL
        AND (subscription_duration not in (1, 6) OR is_in_intro_offer_period is not TRUE)
    ),

    sub_country AS (
    SELECT DISTINCT country, market
    FROM der.subscriptions_events
    JOIN intermediate.market_mapping USING (country)
    WHERE subscription_type = 'Subscription Purchased'
        AND country IS NOT NULL
    ),

    --only get the last 6 months price
    country_price AS (
    SELECT country,
        subscription_duration,
        platform,
        is_in_intro_offer_period,
        ROUND(AVG(gross_sales_euro), 2) AS gross_price,
        ROUND(AVG(gross_sales_full_price_euro), 2) AS gross_full_price
    FROM der.subscriptions_events
    WHERE subscription_type = 'Subscription Purchased'
        AND country IS NOT NULL
        AND backend_created_at >= DATE_TRUNC('month', '{{ execution_date }}'::timestamp) - INTERVAL '6 months'
		AND backend_created_at < DATE_TRUNC('month', '{{ execution_date }}'::timestamp)
    GROUP BY country, subscription_duration, platform, is_in_intro_offer_period
    ),

    -- we don't have price data for a lot of countries in the Rest of World market in the last 12 months, so we'll
        -- calculate the average of all of these countries and substitute that in when we don't have a price.
        -- rest of world price is on average 1/2 that of the price in strategic markets, so this will be more accurate
        -- than substituting in the global average
    market_price AS (
    SELECT market,
        subscription_duration,
        platform,
        is_in_intro_offer_period,
        ROUND(AVG(gross_sales_euro), 2) AS market_gross_price,
        ROUND(AVG(gross_sales_full_price_euro), 2) AS market_gross_full_price
    FROM der.subscriptions_events
    JOIN intermediate.market_mapping USING (country)
    WHERE subscription_type = 'Subscription Purchased'
        AND country IS NOT NULL
        AND backend_created_at >= DATE_TRUNC('month', '{{ execution_date }}'::timestamp) - INTERVAL '6 months'
		AND backend_created_at < DATE_TRUNC('month', '{{ execution_date }}'::timestamp)
    GROUP BY market, subscription_duration, platform, is_in_intro_offer_period
    ),
    
    sample_weights AS (
    SELECT 
        starting_subscription_duration as subscription_duration,
        country, 
        platform,
        started_in_intro_offer_period as is_in_intro_offer_period,
        COUNT(subscription_id) as subscription_count
    FROM der.subscription_history
    WHERE first_purchased_at BETWEEN '{{ execution_date }}'::timestamp - '90 days'::interval AND '{{ execution_date }}'::timestamp
    GROUP BY subscription_duration, country, platform, is_in_intro_offer_period
    ),

    predicted_revenue AS (
    SELECT
        country,
        market,
        subscription_duration,
        platform,
        is_in_intro_offer_period,
        months_into_lifecycle AS retention_curve,
        COALESCE(subscription_count, 0) as sample_weight,
        CASE WHEN months_into_lifecycle = 0
                THEN 100
             ELSE predicted_renewal_rate * 100
        END as renewal_rate,
        CASE WHEN months_into_lifecycle = 0 THEN NULL
            WHEN subscription_duration = 1 AND renewal_rate IS NULL
                THEN months_into_lifecycle - COUNT(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform, is_in_intro_offer_period
                    ORDER BY months_into_lifecycle ROWS UNBOUNDED PRECEDING)
            WHEN subscription_duration IN(6, 12) AND renewal_rate IS NULL AND MOD(months_into_lifecycle, subscription_duration) = 0
                THEN months_into_lifecycle / subscription_duration - COUNT(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform, is_in_intro_offer_period
                    ORDER BY months_into_lifecycle ROWS UNBOUNDED PRECEDING)
            ELSE NULL
        END AS renewal_periods,
        COALESCE(gross_price, market_gross_price) AS gross_price,
        COALESCE(gross_full_price, market_gross_full_price) AS gross_full_price,
        CASE WHEN months_into_lifecycle = 0 THEN 100
            WHEN subscription_duration = 1 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform, is_in_intro_offer_period
                    ORDER BY months_into_lifecycle
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.95, renewal_periods))
            WHEN subscription_duration = 6 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform, is_in_intro_offer_period
                    ORDER BY months_into_lifecycle
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.75, renewal_periods))
            WHEN subscription_duration = 12 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform, is_in_intro_offer_period
                    ORDER BY months_into_lifecycle
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.85, renewal_periods))
            ELSE renewal_rate
        END AS predicted_rate,
        ROUND(
            CASE
                WHEN is_in_intro_offer_period AND months_into_lifecycle != 0
                THEN COALESCE(gross_full_price, market_gross_full_price) * predicted_rate/100
            ELSE
                COALESCE(gross_price, market_gross_price) * predicted_rate/100
            END
            ,2) AS revenue
    FROM offsets
    CROSS JOIN sub_country
    CROSS JOIN sub_duration
    LEFT JOIN intermediate.predicted_segmented_renewal_rates USING(subscription_duration, country, platform, months_into_lifecycle)
    LEFT JOIN country_price USING (subscription_duration, country, platform, is_in_intro_offer_period)
    LEFT JOIN market_price USING (subscription_duration, market, platform, is_in_intro_offer_period)
    LEFT JOIN sample_weights USING (subscription_duration, country, platform, is_in_intro_offer_period)
    )

SELECT predicted_revenue.*,
    retention_curve / 12 AS year_n,
    CASE WHEN year_n = 0 THEN ROUND((revenue) * 0.7, 2) --store rate 1st year is 30%
        ELSE ROUND((revenue) * 0.85, 2) --store rate after 1st year is 15%
    END AS net_revenue,
    SUM(net_revenue) OVER (
        PARTITION BY platform, country, subscription_duration, is_in_intro_offer_period
        ORDER BY retention_curve ROWS UNBOUNDED PRECEDING) AS ltv,
    '{{ execution_date }}'::TIMESTAMP AS created_execution_date
FROM predicted_revenue
WHERE predicted_rate IS NOT NULL
ORDER BY country, subscription_duration, platform, is_in_intro_offer_period, retention_curve
);
