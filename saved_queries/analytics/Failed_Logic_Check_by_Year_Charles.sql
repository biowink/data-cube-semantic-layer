
SELECT 'New Logic' AS table_source,
       DATE_TRUNC('year', backend_created_at) AS month,
       SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN gross_sales_euro END) AS purchase_sales,
       SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN 1 END) AS purchase_count,
       SUM(CASE WHEN subscription_type = 'Subscription Renewed' THEN gross_sales_euro END) AS renewal_sales,
       SUM(CASE WHEN subscription_type = 'Subscription Renewed' THEN 1 END) AS renewal_count,
       SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN -1*gross_sales_euro END) AS refund_sales,
       SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN 1 END) AS refund_count,
       purchase_sales + renewal_sales + NVL(refund_sales, 0) AS total_sales,
       SUM(CASE WHEN subscription_type = 'Subscription Free Trial' THEN 1 END) AS trial_count
FROM dev.subscriptions_events
WHERE backend_created_at >= '2020-01-01'
GROUP BY 1, 2
UNION ALL
SELECT 'Current Status' AS table_source,
       DATE_TRUNC('year', backend_created_at) AS month,
       SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN gross_sales_euro END) AS purchase_sales,
       SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN 1 END) AS purchase_count,
       SUM(CASE WHEN subscription_type = 'Subscription Renewed' THEN gross_sales_euro END) AS renewal_sales,
       SUM(CASE WHEN subscription_type = 'Subscription Renewed' THEN 1 END) AS renewal_count,
       SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN -1*gross_sales_euro END) AS refund_sales,
       SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN 1 END) AS refund_count,
       purchase_sales + renewal_sales + NVL(refund_sales, 0) AS total_sales,
       SUM(CASE WHEN subscription_type = 'Subscription Free Trial' THEN 1 END) AS trial_count
FROM der.subscriptions_events
WHERE backend_created_at >= '2020-01-01'
GROUP BY 1, 2
;