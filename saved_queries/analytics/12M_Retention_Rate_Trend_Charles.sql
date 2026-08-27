SELECT
    DATE_TRUNC('quarter', "month") AS quarter,
    CASE WHEN is_retained THEN 'Retained, ' ELSE 'Churned, ' END || CASE WHEN sessions.analytics_id IS NOT NULL THEN 'Active' ELSE 'Inactive' END AS segment,
    COUNT(DISTINCT subscriber_monthly_retention.analytics_id) AS count_users
FROM der.subscriber_monthly_retention
LEFT JOIN der.sessions ON "month" - INTERVAL '1' MONTH = DATE_TRUNC('month', session_start)
    AND session_start >= DATE '2022-12-01' AND sessions.analytics_id = subscriber_monthly_retention.analytics_id
    AND count_exit_data_entry > 0
WHERE
    initial_subscription_duration = 12
    AND months_into_lifecycle = 12
    AND "month" BETWEEN DATE '2023-01-01' AND DATE '2026-03-31'
GROUP BY 1, 2
ORDER bY 1, 2;