
SELECT user_first_session_attributes.major_app_version,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       COUNT(DISTINCT CASE WHEN subscriptions_events.backend_created_at::DATE = account_created_at::DATE 
           THEN users.analytics_id END) AS count_d0_converters,
    count_d0_converters::FLOAT/count_users AS d0_cvr

FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
INNER JOIN user_metrics.user_onboarding_funnel USING (analytics_id)
LEFT JOIN der.subscriptions_events USING (analytics_id)
LEFT JOIN der.backend_gympass_users USING (analytics_id)
WHERE backend_gympass_users.analytics_id IS NULL AND account_created_at >= '2023-04-10'
  AND user_first_session_attributes.platform = 'android' 
  AND user_first_session_attributes.major_app_version >= 120
GROUP BY 1
HAVING count_users > 1000
ORDER BY 1 DESC
;