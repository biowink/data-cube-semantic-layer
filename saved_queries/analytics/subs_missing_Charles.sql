SELECT
    DATE_TRUNC('week', event_time) AS week,
    COUNT(*) AS count_create_events,
    AVG(CASE WHEN trial_end_date IS NULL THEN 1.0 ELSE 0 END) AS share_missing_trial_end_date
FROM airbyte.backend_mondia_subscription_notifications
WHERE event = 'CREATE'
GROUP BY 1
ORDER BY 1
;