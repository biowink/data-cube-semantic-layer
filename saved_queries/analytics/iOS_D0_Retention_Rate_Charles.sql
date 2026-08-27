SELECT DATE_TRUNC('month', account_created_at) AS month,
       COUNT(DISTINCT users.analytics_id) AS cohort_size,
       COUNT(DISTINCT sessions.analytics_id) AS retained,
       retained::FLOAT/cohort_size AS retention_Rate
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
LEFT JOIN user_metrics.revoke_usage_analytics_user USING (analytics_id)
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id
  AND DATEDIFF('day', account_created_at, session_start) = 1
WHERE account_created_at >= '2023-01-01'
  AND user_first_session_attributes.platform = 'ios'
  AND user_first_session_attributes.country_name = 'United States'
  AND account_created_at < CURRENT_DATE - 1
  AND consent_usage_analytics_revoke_ts IS NULL
GROUP BY 1
ORDER BY 1
;