WITH m12_retained AS (
SELECT DISTINCT users.analytics_id, user_first_session_attributes.platform
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ON user_first_session_attributes.analytics_id = users.analytics_id
INNER JOIN der.sessions ON users.analytics_id = sessions.analytics_id
    AND DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', session_start)) = 12
    AND session_start >= DATE '2021-01-01'
WHERE account_created_at >= DATE '2021-01-01'
    AND account_created_at < DATE '2024-09-01'
)
SELECT DATE_TRUNC('month', account_created_at) AS account_created_month,
m12_retained.platform,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       SUM(count_view_subscription_plans) * 1.0/COUNT(DISTINCT users.analytics_id) AS m12_buy_screen_views
FROM der.users AS users
INNER JOIN m12_retained ON users.analytics_id = m12_retained.analytics_id
LEFT JOIN der.subscription_history ON subscription_history.analytics_id = users.analytics_id
                                          AND DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', first_purchased_at)) < 12
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id
    AND DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', session_start)) < 12
    AND session_start >= DATE '2023-06-01'
WHERE account_created_at >= DATE '2023-06-01'
    AND account_created_at < DATE '2024-10-01'
    AND subscription_history.analytics_id IS NULL
GROUP BY 1, 2
ORDER BY 1, 2
;