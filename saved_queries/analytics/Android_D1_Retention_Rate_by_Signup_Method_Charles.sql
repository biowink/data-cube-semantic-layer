SELECT DATE_TRUNC('week', account_created_at) AS date,
did_create_account_method = 'email' AS email_signup,
    COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT users.analytics_id) AS d1_retention_rate
FROM der.users
INNER JOIN user_metrics.user_onboarding_funnel ON users.analytics_id = user_onboarding_funnel.analytics_id
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id 
    AND DATE_DIFF('day', account_created_at, session_start) = 1
    AND session_start >= DATE '2024-11-01'
WHERE account_created_at >= DATE '2024-11-01'
    AND account_created_at < CURRENT_DATE - INTERVAL '2' DAY
    AND user_onboarding_funnel.platform = 'android'
    AND did_create_account_method IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;