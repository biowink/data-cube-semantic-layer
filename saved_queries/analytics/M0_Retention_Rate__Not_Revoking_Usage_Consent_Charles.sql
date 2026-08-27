SELECT DATE_TRUNC('month', account_created_at) AS MONTH,
       COUNT(DISTINCT users.analytics_id) AS n_users_created,
       COUNT(DISTINCT sessions.analytics_id) AS n_users_with_sessions,
       COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT users.analytics_id) AS m0_retention_rate
FROM der.users
LEFT JOIN user_metrics.user_last_optional_consent_status consents ON users.analytics_id = consents.analytics_id
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id
AND DATE_DIFF('day', account_created_at, session_start) <= 30
WHERE account_created_at >= DATE '2024-01-01'
  AND account_created_at < DATE '2024-12-01'
  AND consent_usage_analytics_revoke_ts IS NULL
GROUP BY 1
ORDER BY 1 ;