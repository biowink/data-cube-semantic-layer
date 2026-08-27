-- /*

-- TABLE SCHEMA

DROP TABLE intermediate.subscriptions_retentions_copy;

CREATE TABLE IF NOT EXISTS intermediate.subscriptions_retentions_copy (
    start_month TIMESTAMP WITH TIME ZONE ENCODE ZSTD,
    month_diff BIGINT ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR(50) ENCODE ZSTD,
    country VARCHAR ENCODE ZSTD,
    price_bucket VARCHAR ENCODE ZSTD,
    new_subscriptions VARCHAR(36) ENCODE ZSTD,
    renewal VARCHAR(36) ENCODE ZSTD
);

-- */

TRUNCATE TABLE intermediate.subscriptions_retentions_copy;

INSERT INTO intermediate.subscriptions_retentions_copy (
    start_month,
    month_diff,
    subscription_duration,
    platform,
    country,
    price_bucket,
    new_subscriptions,
    renewal
)
(
WITH offsets AS (
	SELECT
		ROW_NUMBER() OVER () AS i
	FROM
		der.subscriptions_events
	LIMIT 36
),
new_subs AS (
SELECT
	started_at,
	subscription_id,
	subscription_duration,
	platform,
	country,
	CASE WHEN subscription_duration = 12 THEN
		     CASE WHEN gross_sales_euro < 18 THEN '<18'
		          WHEN gross_sales_euro < 32 THEN '<32'
		          ELSE '32+'
		          END
		 ELSE 'none' END
		   AS price_bucket
FROM
	der.subscriptions_events
WHERE
	subscription_type = 'Subscription Purchased'
	AND backend_created_at < '2022-03-01'
GROUP BY
	started_at,
	subscription_id,
	subscription_duration,
	platform,
	country,
	price_bucket
),
renewal_subs AS (
SELECT
	backend_created_at,
	subscription_id
FROM
	der.subscriptions_events
WHERE
	subscription_type = 'Subscription Renewed'
	AND backend_created_at < '2022-03-01'
GROUP BY
	backend_created_at,
	subscription_id
)
SELECT
	DATE_TRUNC('month', started_at) AS start_month,
	offsets.i AS month_diff,
	subscription_duration,
	platform,
	country,
	price_bucket,
	new_subs.subscription_id AS new_subscriptions,
	CASE WHEN renewal_subs.subscription_id IS NOT NULL THEN
		renewal_subs.subscription_id
	END AS renewal
FROM
	new_subs
	JOIN offsets ON i < DATEDIFF('month', DATE(started_at), '2022-03-01')
	LEFT JOIN renewal_subs ON new_subs.subscription_id = renewal_subs.subscription_id
		AND DATEDIFF('month', DATE(started_at), DATE(renewal_subs.backend_created_at)) = offsets.i
WHERE
	started_at >= '2020-01-01'
GROUP BY
	DATE_TRUNC('month', started_at),
	month_diff,
	subscription_duration,
	platform,
	country,
	price_bucket,
	new_subscriptions,
	renewal
);

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- /*

-- TABLE SCHEMA

DROP TABLE der.ltv_copy;

CREATE TABLE IF NOT EXISTS der.ltv_copy (
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR ENCODE ZSTD,
    price_bucket VARCHAR ENCODE ZSTD,
    retention_curve BIGINT ENCODE ZSTD,
    renewals BIGINT ENCODE ZSTD,
    new_subscriptions BIGINT ENCODE ZSTD,
    renewal_rate DOUBLE PRECISION ENCODE ZSTD,
    renewal_periods BIGINT ENCODE ZSTD,
    gross_price DOUBLE PRECISION ENCODE ZSTD,
    predicted_rate DOUBLE PRECISION ENCODE ZSTD,
    revenue DOUBLE PRECISION ENCODE ZSTD,
    year_n BIGINT ENCODE ZSTD,
    net_revenue DOUBLE PRECISION ENCODE ZSTD,
    ltv DOUBLE PRECISION ENCODE ZSTD
);

-- */

TRUNCATE TABLE der.ltv_copy;

INSERT INTO der.ltv_copy (
    subscription_duration,
    platform,
    price_bucket,
    retention_curve,
    renewals,
    new_subscriptions,
    renewal_rate,
    renewal_periods,
    gross_price,
    predicted_rate,
    revenue,
    year_n,
    net_revenue,
    ltv
)
(
WITH
    offsets AS (
    SELECT ROW_NUMBER() OVER () - 1 AS i
    FROM der.subscriptions_events
    LIMIT 36),

    sub_duration AS (
    SELECT DISTINCT subscription_duration,
        platform,
    	CASE WHEN subscription_duration = 12 THEN
    		     CASE WHEN gross_sales_euro < 18 THEN '<18'
    		          WHEN gross_sales_euro < 32 THEN '<32'
    		          ELSE '32+'
    		          END
    		 ELSE 'none' END
    		   AS price_bucket
    FROM der.subscriptions_events
    WHERE subscription_duration IS NOT NULL),

    price AS (
    SELECT subscription_duration,
           platform,
        	CASE WHEN subscription_duration = 12 THEN
        		     CASE WHEN gross_sales_euro < 18 THEN '<18'
        		          WHEN gross_sales_euro < 32 THEN '<32'
        		          ELSE '32+'
        		          END
        		 ELSE 'none' END
        		   AS price_bucket,
        ROUND(AVG(gross_sales_euro), 2) AS gross_price
    FROM der.subscriptions_events
    WHERE subscription_type = 'Subscription Purchased'
        AND country IS NOT NULL
    GROUP BY subscription_duration, platform, price_bucket),

    all_renewal_rate AS (
    SELECT month_diff,
        subscription_duration,
        platform,
        price_bucket,
        COUNT(DISTINCT renewal) as renewals,
        COUNT(DISTINCT new_subscriptions) as new_subscriptions,
        CASE
            WHEN subscription_duration = 1 OR
                (subscription_duration = 6 AND month_diff IN (6,12,18,24)) OR
                (subscription_duration = 12 AND month_diff IN (12,24))
            THEN
                ROUND(COUNT(DISTINCT renewal)::FLOAT/COUNT(DISTINCT new_subscriptions)*100)
            ELSE
                NULL
        END AS renewal_rate
    FROM intermediate.subscriptions_retentions_copy
    GROUP BY
        month_diff,
        subscription_duration,
        platform,
        price_bucket),

    predicted_revenue AS (
    SELECT d.subscription_duration,
        d.platform,
        d.price_bucket,
        i AS retention_curve,
        renewals,
        new_subscriptions,
        CASE
            --add same month renewal rate as 100% to get full price
            WHEN i = 0
                THEN 100
            ELSE renewal_rate
        END AS renewal_rate,
        --create an offset to calculate the prediction rate using the last value of the renewal rate
        CASE
            WHEN i = 0
                THEN NULL
            WHEN d.subscription_duration = 1 AND renewal_rate IS NULL
                THEN retention_curve - COUNT(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY d.subscription_duration, d.platform, d.price_bucket
                    ORDER BY d.subscription_duration, d.platform, d.price_bucket, i
                    ROWS UNBOUNDED PRECEDING)
            WHEN d.subscription_duration IN (6,12) AND renewal_rate IS NULL
                AND MOD(retention_curve, d.subscription_duration) = 0
                THEN retention_curve / d.subscription_duration - COUNT(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY d.subscription_duration, d.platform, d.price_bucket
                    ORDER BY d.subscription_duration, d.platform, d.price_bucket, i
                    ROWS UNBOUNDED PRECEDING)
            ELSE
                NULL
        END AS renewal_periods,
        gross_price,
        CASE
            WHEN i = 0
                THEN 100
            WHEN d.subscription_duration = 1 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    ORDER BY d.subscription_duration, d.platform, d.price_bucket, i
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.95, renewal_periods))
            WHEN d.subscription_duration IN (6,12) AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    ORDER BY d.subscription_duration, d.platform, d.price_bucket, i
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.95, renewal_periods))
        ELSE
            renewal_rate
        END AS predicted_rate,
        ROUND(gross_price * predicted_rate/100,2) AS revenue
    FROM offsets
        CROSS JOIN sub_duration d
        LEFT JOIN all_renewal_rate r ON i = month_diff
            AND d.subscription_duration = r.subscription_duration
            AND d.price_bucket = r.price_bucket
            AND d.platform = r.platform
        LEFT JOIN price p ON d.subscription_duration = p.subscription_duration
            AND d.price_bucket = p.price_bucket
            AND d.platform = p.platform)

SELECT
    predicted_revenue.*,
    retention_curve / 12 AS year_n,
    CASE WHEN year_n = 0 THEN ROUND((revenue) * 0.7, 2) --store rate 1st year is 30%
        ELSE ROUND((revenue) * 0.85, 2) --store rate after 1st year is 15%
    END AS net_revenue,
    SUM(net_revenue) OVER (
        PARTITION BY subscription_duration, platform, price_bucket
        ORDER BY retention_curve
        ROWS UNBOUNDED PRECEDING) AS ltv
FROM predicted_revenue
WHERE predicted_rate IS NOT NULL
ORDER BY subscription_duration
);

