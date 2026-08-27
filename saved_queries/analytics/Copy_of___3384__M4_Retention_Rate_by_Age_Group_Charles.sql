SELECT DATE_TRUNC('month', account_created_at) AS month,
        DATE_DIFF('year', birthday, account_created_at) <= 20 AS is_young_user,
    COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT users.analytics_id) AS retention_rate
FROM der.users
INNER JOIN der.profiles ON users.analytics_id = profiles.analytics_id
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id 
                              AND DATE_DIFF('day', account_created_at, session_start) BETWEEN 121 AND 150
                              AND session_start >= DATE '2023-08-01'
WHERE DATE_DIFF('year', birthday, account_created_at) BETWEEN 12 AND 50
    AND account_created_at >= DATE '2023-06-01'
    AND account_created_at < DATE '2024-11-01'
GROUP BY 1, 2
ORDER BY 1, 2