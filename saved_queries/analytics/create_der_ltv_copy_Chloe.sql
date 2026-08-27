-- /*

-- TABLE SCHEMA

DROP TABLE der.ltv_copy;

CREATE TABLE IF NOT EXISTS der.ltv_copy (
    execution_date TIMESTAMP WITH TIME ZONE ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    retention_curve BIGINT ENCODE ZSTD,
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
    execution_date,
    subscription_duration,
    retention_curve,
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
    SELECT DISTINCT subscription_duration
    FROM der.subscriptions_events
    WHERE subscription_duration IS NOT NULL),

    price AS (
    SELECT subscription_duration,
        ROUND(AVG(gross_sales_euro), 2) AS gross_price
    FROM der.subscriptions_events
    WHERE subscription_type = 'Subscription Purchased'
        AND country IS NOT NULL
    GROUP BY subscription_duration),

    all_renewal_rate AS (
    SELECT '2022-03-01'::timestamptz AS execution_date, 
        month_diff,
        subscription_duration,
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
        execution_date,
        month_diff,
        subscription_duration),

    predicted_revenue AS (
    SELECT r.execution_date,
        d.subscription_duration,
        i AS retention_curve,
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
                    PARTITION BY r.execution_date, d.subscription_duration
                    ORDER BY d.subscription_duration, i
                    ROWS UNBOUNDED PRECEDING)
            WHEN d.subscription_duration IN (6,12) AND renewal_rate IS NULL
                AND MOD(retention_curve, d.subscription_duration) = 0
                THEN retention_curve / d.subscription_duration - COUNT(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY r.execution_date, d.subscription_duration
                    ORDER BY d.subscription_duration, i
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
                    PARTITION BY r.execution_date
                    ORDER BY d.subscription_duration, i
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.95, renewal_periods))
            WHEN d.subscription_duration IN (6,12) AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY r.execution_date, d.subscription_duration
                    ORDER BY d.subscription_duration, i
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.95, renewal_periods))
        ELSE
            renewal_rate
        END AS predicted_rate,
        ROUND(gross_price * predicted_rate/100,2) AS revenue
    FROM offsets
        CROSS JOIN sub_duration d
        LEFT JOIN all_renewal_rate r ON i = month_diff
            AND d.subscription_duration = r.subscription_duration
        LEFT JOIN price p ON d.subscription_duration = p.subscription_duration)

SELECT
    predicted_revenue.*,
    retention_curve / 12 AS year_n,
    CASE WHEN year_n = 0 THEN ROUND((revenue) * 0.7, 2) --store rate 1st year is 30%
        ELSE ROUND((revenue) * 0.85, 2) --store rate after 1st year is 15%
    END AS net_revenue,
    SUM(net_revenue) OVER (
        PARTITION BY execution_date, subscription_duration
        ORDER BY retention_curve
        ROWS UNBOUNDED PRECEDING) AS ltv
FROM predicted_revenue
WHERE predicted_rate IS NOT NULL
ORDER BY subscription_duration
);
