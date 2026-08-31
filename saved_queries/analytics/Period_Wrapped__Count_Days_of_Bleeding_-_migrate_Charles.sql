SELECT COUNT(*) AS count_period_days
FROM der.backend_tracking
INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
WHERE
    backend_updated_at BETWEEN DATE '2024-10-30' AND DATE '2025-10-30'
    AND revision_type = 'measurements_tracked'
    AND category = 'period'
    AND consent_health_analytics_revoke_ts IS NULL
    AND consent_usage_analytics_revoke_ts IS NULL
;