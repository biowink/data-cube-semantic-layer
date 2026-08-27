SELECT DATE(backend_created_at) AS date,
    COUNT(*) AS count_subscriptions
FROM snapshots.all_subscriptions_events_past_thirty_days
WHERE snapshot_created_execution_date = DATE('2025-01-05')
    AND backend_created_at > DATE('2024-12-01')
    AND platform = 'ios'
    AND original_subscription_type = 'Subscription Purchased'
GROUP BY 1
ORDER BY 1 DESC
LIMIT 500
;