SELECT
    cycle_phase_new_users.platform,
    DATE_DIFF('year', birthday, account_created_at) AS age,
    COUNT(*) AS count_users,
    AVG(CASE WHEN count_d1_sessions > 0 THEN 1.0 ELSE 0 END) AS d1_retention_rate,
    AVG(CASE WHEN count_d7_tracking_days >= 2 AND count_d7_tracking_points >= 5 THEN 1.0 ELSE 0 END) AS activation_rate,
    AVG(count_d7_tracking_points * 1.0) AS avg_d7_tracking_points,
    AVG(count_d7_period_tracking_points * 1.0) AS avg_d7_period_tracking_points,
    AVG(count_d7_period_tracking_points * 1.0/NULLIF(count_d7_tracking_points, 0)) AS avg_d7_tracking_points_share_period,
    AVG(count_d7_tracking_categories * 1.0) AS avg_d7_tracking_categories,
    AVG((count_d7_tracking_points - count_d7_period_tracking_points) * 1.0) AS avg_d7_nonperiod_tracking_points,
    AVG(CASE WHEN count_m2_sessions > 0 THEN 1.0 ELSE 0 END) AS m2_retention_rate,
    AVG(CASE WHEN DATE_DIFF('day', account_created_at, conversion_ts) <= 30 THEN 1.0 ELSE 0 END) AS d30_paid_cvr
FROM temp.cycle_phase_new_users
INNER JOIN user_metrics.user_onboarding_funnel USING (analytics_id)
INNER JOIN user_metrics.new_user_activation_metrics USING (analytics_id)
INNER JOIN user_metrics.new_user_retention_metrics USING (analytics_id)
LEFT JOIN user_metrics.user_last_birth_control_settings USING (analytics_id)
LEFT JOIN user_metrics.user_subscription_status USING (analytics_id)
LEFT JOIN der.profiles USING (analytics_id)
WHERE assign_onboarding_mode_mode = 'period tracking' AND DATE(finish_onboarding_ts) = DATE(account_created_at)
    AND DATE_DIFF('year', birthday, account_created_at) BETWEEN 10 AND 50
GROUP BY 1, 2
ORDER BY 1, 2