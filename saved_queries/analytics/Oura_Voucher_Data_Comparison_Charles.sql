SELECT
    'historical snapshot' AS data_source,
    COUNT(id) AS count_transactions,
    COUNT(DISTINCT analytics_id) AS count_users,
    COUNT(CASE WHEN subscription_type = 'Subscription Voucher' THEN id END) AS count_granted_transactions,
    COUNT(DISTINCT CASE WHEN subscription_type = 'Subscription Voucher' THEN analytics_id END) AS count_granted_users
FROM snapshots.all_subscriptions_events_past_thirty_days
WHERE snapshot_created_execution_date = DATE('2024-11-02')
    AND backend_created_at < DATE('2024-11-03')
    AND code = 'CLU-3MO-SUB'
GROUP BY 1
UNION ALL
SELECT
    'current data' AS data_source,
    COUNT(id) AS count_transactions,
    COUNT(DISTINCT analytics_id) AS count_users,
    COUNT(CASE WHEN subscription_type = 'Subscription Voucher' THEN id END) AS count_granted_transactions,
    COUNT(DISTINCT CASE WHEN subscription_type = 'Subscription Voucher' THEN analytics_id END) AS count_granted_users
FROM der.all_subscriptions_events
WHERE backend_created_at < DATE('2024-11-03')
    AND code = 'CLU-3MO-SUB'
GROUP BY 1
ORDER BY 1 DESC
;