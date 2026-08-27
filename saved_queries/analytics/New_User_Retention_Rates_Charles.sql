SELECT
    user_first_session_attributes.platform,
    DATE_TRUNC('month', account_created_at) AS account_created_month,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('day', account_created_at, session_start) = 1 THEN users.analytics_id END) * 1.0/
        COUNT(DISTINCT users.analytics_id) AS d1_retention_rate,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('day', account_created_at, session_start) BETWEEN 31 AND 60 THEN users.analytics_id END) * 1.0/
        COUNT(DISTINCT users.analytics_id) AS m2_retention_rate,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('day', account_created_at, session_start) BETWEEN 61 AND 90 THEN users.analytics_id END) * 1.0/
        COUNT(DISTINCT users.analytics_id) AS m3_retention_rate
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id
    AND DATE_DIFF('day', account_created_at, session_start) BETWEEN 0 AND 90
    AND session_start >= DATE '2024-07-01'
WHERE
    account_created_at BETWEEN DATE '2024-07-01' AND DATE '2025-08-01'
    AND user_first_session_attributes.platform IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;