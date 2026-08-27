SELECT DATE_TRUNC('week', account_created_at::DATE) AS account_created_at,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       COUNT(DISTINCT CASE WHEN subscriptions_events.backend_created_at::DATE = account_created_at::DATE 
           THEN users.analytics_id END) AS count_d0_converters,
    count_d0_converters::FLOAT/count_users AS d0_cvr

FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
LEFT JOIN der.subscriptions_events USING (analytics_id)
LEFT JOIN der.backend_gympass_users USING (analytics_id)
WHERE backend_gympass_users.analytics_id IS NULL AND account_created_at >= '2023-04-01'
  AND user_first_session_attributes.platform = 'ios'
GROUP BY 1
ORDER BY 1 DESC
;