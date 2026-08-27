SELECT
    DATE(account_created_at) AS date,
    'backend_users_db' AS data_source,
    COUNT(DISTINCT analytics_id) AS count_users
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
WHERE account_created_at >= DATE '2026-01-01'
    AND platform = 'android'
GROUP BY 1, 2
UNION ALL
SELECT
    DATE(derived_tstamp) AS date,
    'sp_events' AS data_source,
    COUNT(DISTINCT analytics_id) AS count_users
FROM der.events
WHERE derived_tstamp >= DATE '2026-01-01'
    AND platform = 'android'
    AND mobile_event_name = 'Did Create Account'
GROUP BY 1, 2
ORDER BY 1, 2
