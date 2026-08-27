WITH install_counts AS (
    SELECT
        DATE_TRUNC('quarter', date) AS cohort_quarter,
        SUM(installs) AS total_installs
    FROM
        der.adjust_campaign_performance_aggregate
    WHERE
        date NOT BETWEEN DATE '2022-12-01' AND DATE '2023-02-01'
    AND date >= DATE '2020-10-01'
    AND date < DATE '2025-04-01'
GROUP BY
    1
ORDER BY
    1 DESC ),
    cross_join AS (
    SELECT 1 + (ROW_NUMBER() OVER (ORDER BY date) - 1) * 32 AS index_number
    FROM static.calendar
    LIMIT 37
    ),
        revenue AS (
SELECT
    DATE_TRUNC('quarter', account_created_at) AS cohort_quarter,
    account_created_at,
    backend_created_at,
    net_sales_euro
FROM
    der.all_subscriptions_events
INNER JOIN der.users USING (analytics_id)
WHERE
    account_created_at NOT BETWEEN DATE '2022-12-01'
    AND DATE '2023-02-01'
    AND account_created_at >= DATE '2020-10-01'
    AND account_created_at < DATE '2025-04-01'
    AND is_financial_transaction
    AND backend_created_at < DATE '2025-06-01'
    AND backend_created_at >= account_created_at
    )
SELECT DATE(install_counts.cohort_quarter) AS cohort_quarter,
       total_installs,
       index_number,
       SUM(net_sales_euro) AS revenue,
       NULLIF(SUM(net_sales_euro)/total_installs, 0) AS revenue_to_date
FROM install_counts
CROSS JOIN cross_join
LEFT JOIN revenue ON install_counts.cohort_quarter = revenue.cohort_quarter
    AND DATE_DIFF('day', account_created_at, backend_created_at) <= index_number
    AND DATE_ADD('day', index_number, DATE_ADD('month', 3, install_counts.cohort_quarter)) < DATE '2025-06-01'
GROUP BY install_counts.cohort_quarter, total_installs, index_number
ORDER BY 1, 2, 3
;