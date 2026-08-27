SELECT COUNT(DISTINCT analytics_id) AS count_users
FROM der.backend_reminders
INNER JOIN user_metrics.user_last_session_attributes USING (analytics_id)
WHERE 
    session_ts >= CURRENT_DATE - INTERVAL '30' DAY 
    AND enabled