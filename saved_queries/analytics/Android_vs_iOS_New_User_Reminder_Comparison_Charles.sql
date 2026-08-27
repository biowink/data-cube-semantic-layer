SELECT ufsa.platform,
       COUNT(DISTINCT users.analytics_id) AS count_backend_users,
       COUNT(DISTINCT uof.analytics_id) AS count_client_reminders_total,
       COUNT(DISTINCT CASE WHEN json_extract_path_text(event_properties, 'Reminder Enabled') = 'true'
           THEN uof.analytics_id END) AS count_client_reminders_enabled,
       COUNT(DISTINCT bre.analytics_id) AS count_backend_reminders_total,
       COUNT(DISTINCT CASE WHEN bre.enabled THEN bre.analytics_id END) AS count_backend_reminders_enabled,
       count_client_reminders_total::FLOAT/count_backend_users AS share_client_reminders_total,
       count_client_reminders_enabled::FLOAT/count_backend_users AS share_client_reminders_enabled,
       count_backend_reminders_total::FLOAT/count_backend_users AS share_backend_reminders_total,
       count_backend_reminders_enabled::FLOAT/count_backend_users AS share_backend_reminders_enabled
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ufsa ON users.analytics_id = ufsa.analytics_id
LEFT JOIN user_metrics.user_onboarding_funnel uof ON users.analytics_id = uof.analytics_id
LEFT JOIN der.events ON events.sp_device_id = uof.sp_device_id AND mobile_event_name = 'Select Reminder Setup Response'
  AND account_created_at::DATE = derived_tstamp::DATE
LEFT JOIN der.backend_reminder_events bre ON bre.analytics_id = users.analytics_id 
WHERE ufsa.platform IS NOT NULL AND account_created_at >= CURRENT_DATE - 7
    AND ufsa.major_app_version >= 123
GROUP BY 1
ORDER BY 1
;