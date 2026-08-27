WITH daily_sales AS (
    SELECT
        DATE (backend_created_at) AS backend_created_date,
        DATE_TRUNC('month', backend_created_at) AS backend_created_month,
        DAY (backend_created_at) AS backend_create_day_of_month,
        SUM (CASE WHEN subscription_type = 'Subscription Refunded' THEN -1 * gross_sales_euro ELSE gross_sales_euro END) AS gross_sales
FROM
    der.all_subscriptions_events
WHERE
    is_financial_transaction
GROUP BY
    1, 2, 3 ),
    cumulative_sales AS (
SELECT
    backend_created_date, backend_created_month, backend_create_day_of_month, SUM (
    gross_sales) OVER (
    PARTITION BY backend_created_month ORDER BY backend_created_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_gross_sales
FROM
    daily_sales )
SELECT DATE(backend_created_month) AS month,
       MIN(CASE WHEN cumulative_gross_sales > 1000000 THEN backend_create_day_of_month END) AS days_needed_to_hit_one_million
FROM cumulative_sales
WHERE backend_created_month >= DATE '2024-01-01'
GROUP BY 1
ORDER BY 1
