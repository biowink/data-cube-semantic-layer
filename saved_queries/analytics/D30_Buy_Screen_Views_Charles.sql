SELECT DATE_TRUNC('month', account_created_at) AS account_created_month,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       SUM(count_view_subscription_plans) * 1.0/COUNT(DISTINCT users.analytics_id) AS d30_buy_screen_views
FROM der.users
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id
    AND DATE_DIFF('day', account_created_at, session_start) < 30
    AND session_start >= DATE '2021-01-01'
WHERE account_created_at >= DATE '2021-01-01'
    AND account_created_at < DATE '2025-08-01'
GROUP BY 1
ORDER BY 1
;