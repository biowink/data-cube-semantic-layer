SELECT
    created_execution_date,
    COUNT(*) AS count_records
FROM snapshots.all_subscriptions_events_past_thirty_days
GROUP BY 1
ORDER BY 1 DESC
;