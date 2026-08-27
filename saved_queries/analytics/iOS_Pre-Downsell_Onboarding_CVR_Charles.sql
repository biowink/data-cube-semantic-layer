SELECT user_first_session_attributes.major_app_version,
       COUNT(DISTINCT users.analytics_id) AS user_count,
       COUNT(DISTINCT events.analytics_id) * 1.0/COUNT(DISTINCT users.analytics_id) AS onboarding_cvr_corrected
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
LEFT JOIN (SELECT *
FROM der.events FOR TIMESTAMP AS OF TIMESTAMP '2025-05-12 10:00:00'
) events ON users.analytics_id = events.analytics_id
    AND derived_tstamp >= DATE '2025-01-01'
    AND navigation_context = 'onboarding'
    AND mobile_event_name = 'Subscription Started'
    AND JSON_EXTRACT_SCALAR(event_properties, '$["Buy Screen Type"]') = 'standard'
    AND DATE_DIFF('day', account_created_at, derived_tstamp) = 0
WHERE account_created_at >= DATE '2025-01-01'
    AND user_first_session_attributes.platform = 'ios'
    AND user_first_session_attributes.major_app_version >= 209
GROUP BY 1
ORDER BY 1
;