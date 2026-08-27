SELECT
    DATE_TRUNC('month', backend_created_at) AS month,
    'mobile_subscriptions_events' AS data_source,
    COUNT(*) AS count_transactions,
    COUNT(DISTINCT analytics_id) AS count_users,
    SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN -1 * gross_sales_euro ELSE gross_sales_euro END) AS gross_sales_euro,
    SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN -1 * net_sales_euro ELSE net_sales_euro END) AS net_sales_euro
FROM der.mobile_subscriptions_events
WHERE
    platform = 'IOS'
    AND backend_created_at >= DATE '2025-02-01'
    AND backend_created_at < CURRENT_DATE
    AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
GROUP BY 1, 2
UNION ALL
SELECT
    DATE_TRUNC('month', backend_created_at) AS month,
    'new_service_ios_subscriptions_events' AS data_source,
    COUNT(*) AS count_transactions,
    COUNT(DISTINCT analytics_id) AS count_users,
    SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN -1 * gross_sales_euro ELSE gross_sales_euro END) AS gross_sales_euro,
    SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN -1 * net_sales_euro ELSE net_sales_euro END) AS net_sales_euro
FROM temp.new_service_ios_subscriptions_events
WHERE
    platform = 'IOS'
    AND backend_created_at >= DATE '2025-02-01'
    AND backend_created_at < CURRENT_DATE
    AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
GROUP BY 1, 2
ORDER BY 1, 2
;