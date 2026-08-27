SELECT user_last_session_attributes.platform,
       subscriber_monthly_retention.month,
       COUNT(DISTINCT analytics_id) AS count_users,
       COUNT(DISTINCT CASE WHEN is_dau THEN analytics_id END) * 1.0/COUNT(DISTINCT analytics_id) AS paid_mau,
       COUNT(CASE WHEN is_dau THEN analytics_id END) * 1.0/COUNT(DISTINCT CASE WHEN is_dau THEN analytics_id END) AS paid_dau_mau,
       COUNT(CASE WHEN sum_exit_data_entry > 0 THEN analytics_id END) * 1.0/COUNT(DISTINCT CASE WHEN is_dau THEN analytics_id END) AS paid_tracking_dau_mau
FROM der.subscriber_monthly_retention
INNER JOIN user_metrics.user_last_session_attributes USING (analytics_id)
INNER JOIN der.clue_plus_user_lifetimes USING (analytics_id)
WHERE initial_subscription_duration = 12
    AND months_into_lifecycle = 11
    AND user_conversion_cohort BETWEEN DATE '2023-01-01' AND DATE '2024-01-01'
    AND date >= DATE '2024-01-01'
    AND date BETWEEN month AND month + INTERVAL '29' DAY
    AND user_last_session_attributes.platform IS NOT NULL
    AND subscriber_monthly_retention.initial_subscription_source = 'mobile'
GROUP BY 1, 2
ORDER BY 1, 2
;