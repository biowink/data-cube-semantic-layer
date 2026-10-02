SELECT
    DATE_TRUNC('month', session_start) AS month,
    platform,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('day', previous_session_start, session_start) > 30 THEN analytics_id END) *1.0/
        COUNT(DISTINCT analytics_id) AS reactivation_share
FROM der.sessions
INNER JOIN der.users USING (analytics_id)
WHERE
    session_start BETWEEN DATE '2023-07-01' AND DATE '2025-12-01'
    AND analytics_id IS NOT NULL
    AND platform IS NOT NULL
    AND DATE_TRUNC('month', session_start) > account_created_at
GROUP BY 1, 2
ORDER BY 1, 2
;