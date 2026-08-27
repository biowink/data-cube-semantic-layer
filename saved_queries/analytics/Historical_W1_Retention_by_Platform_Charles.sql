SELECT
       user_first_session_attributes.platform,
        DATE_TRUNC('week', users.account_created_at) AS date,
    COUNT(DISTINCT users.analytics_id) AS count_users,
        COUNT(DISTINCT sessions.analytics_id) * 1.0/
            COUNT(DISTINCT users.analytics_id) AS w1_retention_rate
    
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id
                    AND DATE_DIFF('day', account_created_at, session_start) BETWEEN 180 AND 210
                    AND session_start >= DATE '2022-01-01'
WHERE account_created_at >= DATE '2022-01-01' AND account_created_at <= DATE '2024-06-01'
    AND user_first_session_attributes.platform IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2, 3
;