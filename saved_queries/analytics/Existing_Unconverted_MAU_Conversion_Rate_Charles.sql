WITH existing_mau AS (
SELECT DATE_TRUNC('month', session_start) AS month,
       COUNT(DISTINCT sessions.analytics_id) AS count_mau
FROM der.sessions
INNER JOIN der.users ON sessions.analytics_id = users.analytics_id
LEFT JOIN der.subscription_history ON sessions.analytics_id = subscription_history.analytics_id
    AND user_converted_with_this_subscription
    AND first_purchased_at < DATE_TRUNC('month', session_start)
WHERE session_start BETWEEN DATE '2021-01-01' AND DATE '2025-09-01'
    AND subscription_history.analytics_id IS NULL
    AND DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', session_start)) > 0
GROUP BY 1
ORDER BY 1
),
    conversions AS (
    SELECT DATE_TRUNC('month', first_purchased_at) AS month,
        COUNT(DISTINCT analytics_id) AS count_conversions
    FROM der.subscription_history
    INNER JOIN der.users USING (analytics_id)
    WHERE user_converted_with_this_subscription and DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', first_purchased_at)) > 0
    GROUP BY 1
    )
SELECT
    month,
    count_mau,
    count_conversions,
    count_conversions * 1.0/count_mau AS conversion_rate
FROM existing_mau
INNER JOIN conversions USING (month)
ORDER BY 1
;