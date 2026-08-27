SELECT DATE(session_start) AS date,
COUNT(*) AS count_sessions,
AVG(CASE WHEN count_view_subscription_plans > 0 THEN 1.0 ELSE 0 END) AS avg_session_with_buy_screen
FROM der.sessions
INNER JOIN der.users USING (analytics_id)
WHERE DATE_DIFF('day', account_created_at, session_start) BETWEEN 1 AND 31
AND platform = 'ios'
AND session_start >= DATE '2025-07-01'
GROUP BY 1
ORDER BY 1
;