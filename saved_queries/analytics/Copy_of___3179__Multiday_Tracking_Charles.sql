SELECT user_first_session_attributes.major_app_version,
       user_first_session_attributes.platform,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       COUNT(DISTINCT events.analytics_id) * 1.0/COUNT(DISTINCT users.analytics_id) AS share_multiday_tracking
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
LEFT JOIN der.events ON users.analytics_id = events.analytics_id AND events.derived_tstamp >= DATE('2024-09-01')
    AND DATE_DIFF('day', account_created_at, derived_tstamp) = 0 AND mobile_event_name = 'Exit Multi Day Tracker'
WHERE user_first_session_attributes.platform IS NOT NULL
    AND users.account_created_at >= DATE('2024-09-01')
GROUP BY 1, 2
HAVING COUNT(DISTINCT users.analytics_id) > 5000
ORDER BY 1, 2
;