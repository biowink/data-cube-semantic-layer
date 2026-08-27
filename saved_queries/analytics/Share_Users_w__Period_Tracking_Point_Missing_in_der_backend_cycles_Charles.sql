SELECT DATE_TRUNC('day', account_created_at) AS date,
       COUNT(DISTINCT u.analytics_id) AS count_users,
       COUNT(DISTINCT c.analytics_id) AS count_cycle_users,
       1 - COUNT(DISTINCT c.analytics_id) * 1.0/COUNT(DISTINCT u.analytics_id) AS share_users_missing_cycles
FROM der.users u
LEFT JOIN der.backend_cycles c
    ON u.analytics_id = c.analytics_id
INNER JOIN der.backend_tracking t
    ON t.analytics_id = u.analytics_id
    AND category = 'period'
WHERE account_created_at >= DATE '2023-01-01'
GROUP BY 1
ORDER BY 1
;