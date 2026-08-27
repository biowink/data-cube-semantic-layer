SELECT
    major_app_version,
    platform,
    COUNT(DISTINCT users.analytics_id) AS user_count,
    COUNT(DISTINCT CASE WHEN email_is_verified AND DATE_DIFF('hour', account_created_at, users.backend_updated_at) <= 48 THEN users.analytics_id END) * 1.0/COUNT(DISTINCT users.analytics_id) AS verified_rate_backend
FROM der.users
INNER JOIN user_metrics.user_onboarding_funnel ON users.analytics_id = user_onboarding_funnel.analytics_id
WHERE account_created_at BETWEEN DATE '2025-05-22' AND CURRENT_DATE - INTERVAL '3' DAY
    AND did_create_account_method = 'email'
GROUP BY 1, 2
HAVING COUNT(DISTINCT users.analytics_id) > 5000
ORDER BY 1, 2
;