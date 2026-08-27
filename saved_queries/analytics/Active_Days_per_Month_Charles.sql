WITH active_days AS (
SELECT DATE_TRUNC('month', session_start) AS month,
       analytics_id,
        MAX(platform) AS platform,
        COUNT(DISTINCT DATE(session_start)) AS count_active_days
FROM der.sessions
WHERE session_start >= DATE('2023-05-01')
    AND session_start < DATE('2024-12-01')
    AND DAY(session_start) <= 28
    AND platform IS NOT NULL
    AND analytics_id IS NOT NULL
GROUP BY 1, 2
)
SELECT month,
    platform,
    AVG(CASE WHEN count_active_days >= 4 THEN 1.0 ELSE 0 END) AS share_active_4d,
    AVG(CASE WHEN count_active_days >= 8 THEN 1.0 ELSE 0 END) AS share_active_8d,
    AVG(CASE WHEN count_active_days >= 14 THEN 1.0 ELSE 0 END) AS share_active_14d,
    AVG(CASE WHEN count_active_days >= 20 THEN 1.0 ELSE 0 END) AS share_active_20d
FROM active_days
INNER JOIN der.users USING (analytics_id)
WHERE DATE_DIFF('month', account_created_at, active_days.month) >= 12
GROUP BY 1, 2
ORDER BY 1, 2
;