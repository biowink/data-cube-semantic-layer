SELECT DATE(did_create_account_ts) AS date,
    COUNT(*) AS count_users,
    AVG(count_d0_period_tracking_points) AS d0_period_tracking_points
FROM user_metrics.user_onboarding_funnel
LEFT JOIN user_metrics.adjust_attribution USING (analytics_id)
LEFT JOIN user_metrics.new_user_activation_metrics USING (analytics_id)
WHERE platform = 'ios'
    AND did_create_account_ts >= DATE '2025-03-01'
    AND network = 'Organic'
GROUP BY 1
ORDER BY 1
;