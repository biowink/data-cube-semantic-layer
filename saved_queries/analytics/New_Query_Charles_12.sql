SELECT
    DATE(created_at) AS date,
    COUNT(*) AS  count_records
FROM (
            SELECT DISTINCT
                se.*,
                cast(se.transaction_id as bigint) transaction_id,
                coalesce(se.analytics_id, s.analytics_id) AS fixed_analytics_id
            FROM der.backend_subscriptions_events se
            LEFT JOIN der.backend_subscriptions s ON s.id = se.subscription_id
            WHERE se.created_at >= DATE '2025-07-01'
                AND se.transaction_id IS NOT NULL
                AND s.platform = 'IOS'
                AND NOT s.test_subscription
)
GROUP BY 1
ORDER BY 1