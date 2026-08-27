SELECT DATE_TRUNC('week', account_created_at) AS account_created_week,
       user_first_session_attributes.platform,
       COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT users.analytics_id) AS m4_retention_rate
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
LEFT JOIN der.sessions ON sessions.analytics_id = users.analytics_id
    AND DATE_DIFF('day', account_created_at, session_start) BETWEEN 91 AND 120 AND session_start >= DATE('2024-02-01')
WHERE user_first_session_attributes.platform IS NOT NULL
    AND account_created_at >= DATE('2024-01-01')
    AND account_created_at < CURRENT_DATE - INTERVAL '120' DAY
GROUP BY 1, 2
ORDER BY 1, 2
;