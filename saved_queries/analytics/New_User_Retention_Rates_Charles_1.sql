SELECT DATE_TRUNC('month', account_created_at) AS account_created_month,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       COUNT(DISTINCT CASE WHEN DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', session_start)) = 1 THEN sessions.analytics_id END) * 1.0/
        COUNT(DISTINCT users.analytics_id) AS m1_retention_rate,
       COUNT(DISTINCT CASE WHEN DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', session_start)) = 12 THEN sessions.analytics_id END) * 1.0/
        COUNT(DISTINCT users.analytics_id) AS m12_retention_rate,
       COUNT(DISTINCT CASE WHEN DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', session_start)) = 12 THEN sessions.analytics_id END) * 1.0/
        COUNT(DISTINCT CASE WHEN DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', session_start)) = 1 THEN sessions.analytics_id END) AS m1_to_m12_retention
FROM der.users
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id
    AND DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', session_start)) IN (1, 12)
    AND session_start >= DATE '2021-01-01'
WHERE account_created_at >= DATE '2021-01-01'
    AND account_created_at < DATE '2024-09-01'
GROUP BY 1
HAVING DATE_TRUNC('month', account_created_at) NOT BETWEEN DATE '2022-12-01' AND DATE '2023-03-01'
ORDER BY 1
;