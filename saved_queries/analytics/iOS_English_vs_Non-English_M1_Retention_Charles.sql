SELECT DATE_TRUNC('month', account_created_at) AS month,
    user_first_session_attributes.language = 'English' AS is_english,
    COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT users.analytics_id) AS m1_retention
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
LEFT JOIN der.sessions ON sessions.analytics_id = users.analytics_id AND session_start >= DATE('2024-01-01')
    AND DATE_DIFF('day', account_created_at, session_start) BETWEEN 31 AND 60
WHERE
    user_first_session_attributes.platform = 'ios'
    AND account_created_at >= DATE('2024-01-01')
    AND account_created_at < DATE('2024-11-01')
    AND user_first_session_attributes.language IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;