SELECT user_first_session_attributes.major_app_version,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'View Subscription Plans' AND navigation_context = 'onboarding' THEN events.analytics_id END) * 1.0/
        COUNT(DISTINCT users.analytics_id) AS onboarding_buy_screen_view_rate
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
LEFT JOIN der.events ON users.analytics_id = events.analytics_id AND events.derived_tstamp >= DATE('2024-11-01')
    AND DATE_DIFF('day', account_created_at, derived_tstamp) = 0
    AND mobile_event_name IN ('View Subscription Plans')
WHERE user_first_session_attributes.major_app_version >= 178
    AND user_first_session_attributes.platform = 'android'
    AND user_first_session_attributes.session_ts >= DATE('2024-11-01')
GROUP BY 1
ORDER BY 1
;