WITH refunds AS (
SELECT subscription_id
FROM der.subscriptions_events
WHERE subscription_type = 'Subscription Refunded'
),
conversions AS (
SELECT master_id,
subscription_id,
MIN(backend_created_at::DATE) AS subscription_started
FROM der.subscriptions_events
LEFT JOIN refunds USING (subscription_id)
WHERE subscription_type IN ('Subscription Purchased') 
AND refunds.subscription_id IS NULL 
AND started_at >= '2020-07-01'
GROUP BY 1, 2
),
cohorts AS (
SELECT master_id,
DATE_TRUNC('month', MIN(subscription_started)) AS conversion_cohort
FROM conversions
GROUP BY 1
),
cohort_revenue AS (
SELECT conversion_cohort,
DATE_DIFF('month', conversion_cohort, backend_created_at::DATE) AS months_since_conversion,
COUNT(DISTINCT cohorts.master_id) AS cohort_size,
SUM(net_sales_euro) AS total_net_sales_euro
FROM cohorts
INNER JOIN der.subscriptions_events USING (master_id)
INNER JOIN conversions USING (subscription_id)
WHERE subscription_type IN ('Subscription Purchased', 'Subscription Renewed')
  AND months_since_conversion >= 0
  AND conversion_cohort >= '2020-07-01'
GROUP BY 1, 2
)
SELECT conversion_cohort,
months_since_conversion,
SUM(total_net_sales_euro) 
    OVER (PARTITION BY conversion_cohort ORDER BY months_since_conversion ASC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_running_net_sales_euro
FROM cohort_revenue
;

