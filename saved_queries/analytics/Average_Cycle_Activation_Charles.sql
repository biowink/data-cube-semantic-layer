SELECT
       user_onboarding_funnel.platform,
        DATE(users.account_created_at) AS date,
       COALESCE(JSON_EXTRACT_SCALAR(event_properties, '$["Average Cycle"]'), '') != '' AS did_enter_cycle,
        COUNT(DISTINCT CASE WHEN count_d7_tracking_days >= 2 AND count_d7_tracking_points >= 5 THEN users.analytics_id END) * 1.0/ 
            COUNT(DISTINCT users.analytics_id) AS activation_rate
FROM der.users
INNER JOIN user_metrics.user_onboarding_funnel ON users.analytics_id = user_onboarding_funnel.analytics_id
LEFT JOIN
        der.events ON user_onboarding_funnel.sp_device_id = events.sp_device_id
        AND mobile_event_name = 'Select Average Cycle'
        AND derived_tstamp >= DATE '2024-12-01'
INNER JOIN user_metrics.new_user_activation_metrics ON users.analytics_id = new_user_activation_metrics.analytics_id
WHERE account_created_at >= DATE '2024-12-01' AND account_created_at <= DATE '2025-01-20'
    AND user_onboarding_funnel.platform = 'ios'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3