
SELECT
    DATE_TRUNC('week', account_created_at) AS date,
    platform,
    COUNT(*) AS count_users,
    AVG(CASE WHEN email_is_verified AND DATE_DIFF('day', account_created_at, backend_updated_at) <= 3 THEN 1.0 ELSE 0 END) AS share_verified
FROM der.users
INNER JOIN user_metrics.user_onboarding_funnel USING (analytics_id)
WHERE account_created_at >= DATE '2025-08-01'
    AND account_created_at < CURRENT_DATE - INTERVAL '3' DAY
    AND did_create_account_method = 'email'
GROUP BY 1, 2
ORDER BY 1, 2
;