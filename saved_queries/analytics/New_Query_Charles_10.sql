SELECT
    network,
    platform,
    COUNT(DISTINCT users.analytics_id) AS user_count,
    COUNT(DISTINCT CASE WHEN email_is_verified THEN users.analytics_id END) * 1.0/COUNT(DISTINCT users.analytics_id) AS verified_rate_backend
FROM der.users
INNER JOIN user_metrics.user_onboarding_funnel ON users.analytics_id = user_onboarding_funnel.analytics_id
INNER JOIN user_metrics.adjust_attribution ON users.analytics_id = adjust_attribution.analytics_id
WHERE account_created_at BETWEEN DATE '2025-10-01' AND DATE '2026-01-01'
    AND did_create_account_method = 'email'
GROUP BY 1, 2
ORDER BY 1, 2
;