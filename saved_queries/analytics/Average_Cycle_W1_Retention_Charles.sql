SELECT
       user_onboarding_funnel.platform,
        DATE_TRUNC('week', users.account_created_at) AS date,
       COALESCE(JSON_EXTRACT_SCALAR(event_properties, '$["Average Cycle"]'), '') != '' AS did_enter_cycle,
    COUNT(DISTINCT users.analytics_id) AS count_users,
        COUNT(DISTINCT sessions.analytics_id) * 1.0/
            COUNT(DISTINCT users.analytics_id) AS w1_retention_rate
    
FROM der.users
INNER JOIN user_metrics.user_onboarding_funnel ON users.analytics_id = user_onboarding_funnel.analytics_id
LEFT JOIN
        der.events ON user_onboarding_funnel.sp_device_id = events.sp_device_id
        AND mobile_event_name = 'Select Average Cycle'
        AND derived_tstamp >= DATE '2024-09-01'
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id
                    AND DATE_DIFF('day', account_created_at, session_start) = 1
                    AND session_start >= DATE '2024-09-01'
WHERE account_created_at >= DATE '2024-09-01' AND account_created_at <= DATE '2025-01-25'
    AND user_onboarding_funnel.platform = 'ios'
        AND user_onboarding_funnel.select_onboarding_mode_mode = 'period tracking'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;