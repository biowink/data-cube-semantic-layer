SELECT 'sessions' AS source,
       COUNT(DISTINCT analytics_id) AS count_mau
FROM der.sessions
WHERE session_start >= DATE '2025-07-27'
GROUP BY 1
UNION ALL
SELECT 'user_last_session_attributes' AS source,
       COUNT(DISTINCT analytics_id) AS count_mau
FROM user_metrics.user_last_session_attributes
WHERE session_ts >= DATE '2025-07-27'
GROUP BY 1
ORDER BY 1
;