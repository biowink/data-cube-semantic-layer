SELECT
    CASE WHEN type = 'no_sex_today' THEN 'no sex' ELSE 'sex' END AS had_sex,
    COUNT(*) AS count_days,
    COUNT(*)/365 AS avg_daily_count
FROM der.backend_tracking
INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
WHERE
    backend_updated_at BETWEEN DATE '2024-10-30' AND DATE '2025-10-30'
    AND revision_type = 'measurements_tracked'
    AND consent_health_analytics_revoke_ts IS NULL
    AND consent_usage_analytics_revoke_ts IS NULL
    AND category = 'sex_life'
    AND type IN ('no_sex_today', 'unprotected', 'withdrawal', 'protected')
GROUP BY 1
ORDER BY 1
;