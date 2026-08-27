WITH daily_sales AS (
    SELECT
        backend_created_at::DATE AS backend_created_dt,
        SUM(CASE
                WHEN subscription_type IN ('Subscription Purchased', 'Subscription Renewed') THEN gross_sales_euro
                WHEN subscription_type = 'Subscription Refunded' THEN -1 * gross_sales_euro
            END) AS gross_sales_euro
    FROM der.subscriptions_events
    LEFT JOIN static.market_mapping ON subscriptions_events.country = market_mapping.country
    WHERE
            subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
    AND market LIKE '%Strategic%'
    GROUP BY 1
    HAVING backend_created_dt >= '2022-01-01'
)
SELECT DATE_TRUNC('month', backend_created_dt) AS month,
       MEDIAN(gross_sales_euro) AS median,
       MAX(gross_sales_euro) AS max,
       MIN(gross_sales_euro) AS min,
       AVG(gross_sales_euro) AS avg
FROM daily_sales
GROUP BY 1
ORDER BY 1 DESC
;