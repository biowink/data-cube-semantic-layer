SELECT
    platform,
    CASE WHEN DATE(account_created_at) >= DATE '2025-10-15' THEN '2nd Half Oct' ELSE '1st Half Oct' END AS date,
    CASE WHEN consent_product_promotion_revoke_ts IS NULL AND DATE_DIFF('year', birthday, account_created_at) < 19
        THEN TRUE ELSE FALSE END AS is_young_user,
    COUNT(*) AS count_users,
    AVG(LEAST(count_d1_sessions, 1) * 1.0) AS d1_retention
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
INNER JOIN der.profiles USING (analytics_id)
INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
INNER JOIN user_metrics.new_user_retention_metrics USING (analytics_id)
INNER JOIN user_metrics.adjust_attribution USING (analytics_id)
WHERE
    platform = 'ios'
    AND account_created_at >= DATE '2025-10-01'
    AND network = 'Organic'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;