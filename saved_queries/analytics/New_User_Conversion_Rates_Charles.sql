SELECT DATE_TRUNC('month', account_created_at) AS account_created_month,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       COUNT(DISTINCT CASE WHEN DATE_DIFF('day', account_created_at, first_purchased_at) < 30 THEN subscription_history.analytics_id END) AS first_30d_convs,
       COUNT(DISTINCT CASE WHEN DATE_DIFF('day', account_created_at, first_purchased_at) < 30 THEN subscription_history.analytics_id END) * 1.0/
        COUNT(DISTINCT users.analytics_id) AS first_30d_cvr,
       COUNT(DISTINCT CASE WHEN DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', first_purchased_at)) < 12 THEN subscription_history.analytics_id END) AS count_12m_convs,
       COUNT(DISTINCT CASE WHEN DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', first_purchased_at)) < 12 THEN subscription_history.analytics_id END) * 1.0/
        COUNT(DISTINCT users.analytics_id) AS first_12m_cvr,
        COUNT(DISTINCT CASE WHEN DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', first_purchased_at)) < 12 THEN subscription_history.analytics_id END) * 1.0/
        COUNT(DISTINCT CASE WHEN DATE_DIFF('day', account_created_at, first_purchased_at) < 30 THEN subscription_history.analytics_id END) - 1 AS next_11m_gain
        
FROM der.users
LEFT JOIN der.subscription_history ON subscription_history.analytics_id = users.analytics_id AND user_converted_with_this_subscription
WHERE account_created_at >= DATE '2021-01-01'
    AND account_created_at < DATE '2024-10-01'
GROUP BY 1
ORDER BY 1
;