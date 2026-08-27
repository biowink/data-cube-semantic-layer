SELECT
    'backend' AS source,
    DATE_TRUNC('month', backend_created_at) AS month,
    COUNT(*) AS count_records,
    COUNT(DISTINCT subscription_id) AS count_subs,
    COUNT(DISTINCT analytics_id) AS count_users,
    SUM(CASE WHEN subscription_type IN ('Subscription Purchased', 'Subscription Renewed') THEN gross_sales_euro
        WHEN subscription_type = 'Subscription Refunded' THEN -1 * gross_sales_euro END) AS gross_sales_euro
FROM dev.new_service_ios_subscriptions_events
WHERE platform = 'IOS'
GROUP BY 1, 2
UNION ALL
SELECT
    'api' AS source,
    DATE_TRUNC('month', backend_created_at) AS month,
    COUNT(*) AS count_records,
    COUNT(DISTINCT subscription_id) AS count_subs,
    COUNT(DISTINCT analytics_id) AS count_users,
    SUM(CASE WHEN subscription_type IN ('Subscription Purchased', 'Subscription Renewed') THEN gross_sales_euro
        WHEN subscription_type = 'Subscription Refunded' THEN -1 * gross_sales_euro END) AS gross_sales_euro
FROM der.mobile_subscriptions_events
WHERE platform = 'IOS'
GROUP BY 1, 2
ORDER BY 2, 1
;