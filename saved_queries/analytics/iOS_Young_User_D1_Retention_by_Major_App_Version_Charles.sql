SELECT
    platform,
    major_app_version,
    CASE WHEN consent_product_promotion_revoke_ts IS NULL AND DATE_DIFF('year', birthday, account_created_at) < 19
        THEN TRUE ELSE FALSE END AS is_young_user,
    COUNT(*) AS count_users,
    AVG(LEAST(count_d1_sessions, 1) * 1.0) AS d1_retention
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
INNER JOIN der.profiles USING (analytics_id)
INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
INNER JOIN user_metrics.new_user_retention_metrics USING (analytics_id)
WHERE
    platform = 'ios'
    AND account_created_at >= DATE '2025-08-01'
    AND major_app_version >= 233
GROUP BY 1, 2, 3
HAVING COUNT(*) > 1000
ORDER BY 1, 2, 3
;