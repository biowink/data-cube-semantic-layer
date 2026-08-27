SELECT DATE_TRUNC('month', DATE(backend_created_at)) AS month,
       'previous' AS source,
       SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN -1 * gross_sales_euro ELSE gross_sales_euro END)
FROM snapshots.all_subscriptions_events_20240601
WHERE is_financial_transaction AND DATE(backend_created_at) < DATE '2024-06-01'
GROUP BY 1
UNION ALL
SELECT DATE_TRUNC('month', DATE(backend_created_at)) AS month,
       'corrected' AS source,
       SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN -1 * gross_sales_euro ELSE gross_sales_euro END)
FROM der.all_subscriptions_events
WHERE is_financial_transaction AND DATE(backend_created_at) < DATE '2024-06-01'
GROUP BY 1
ORDER BY 1, 2
;