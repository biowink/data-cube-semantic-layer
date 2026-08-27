SELECT
    DATE_TRUNC('week', account_created_at) AS date,
    platform,
    COUNT(DISTINCT users.analytics_id) AS user_count,
    COUNT(DISTINCT CASE WHEN email_is_verified AND DATE_DIFF('hour', account_created_at, users.backend_updated_at) <= 168 THEN users.analytics_id END) * 1.0/COUNT(DISTINCT users.analytics_id) AS verified_rate_backend
FROM der.users
INNER JOIN user_metrics.user_onboarding_funnel ON users.analytics_id = user_onboarding_funnel.analytics_id
INNER JOIN user_metrics.adjust_attribution ON users.analytics_id = adjust_attribution.analytics_id
WHERE account_created_at BETWEEN DATE '2025-04-22' AND CURRENT_DATE - INTERVAL '7' DAY
    AND did_create_account_method = 'email'
    AND network = 'Organic'
GROUP BY 1, 2
ORDER BY 1, 2
;