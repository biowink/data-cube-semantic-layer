WITH total_collection_days AS (
    SELECT COUNT(*) AS count_collection_days
    FROM der.backend_tracking
    INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
    WHERE
        backend_updated_at BETWEEN DATE '2024-10-30' AND DATE '2025-10-30'
        AND revision_type = 'measurements_tracked'
        AND category = 'collection_method'
        AND consent_health_analytics_revoke_ts IS NULL
        AND consent_usage_analytics_revoke_ts IS NULL
)
SELECT
    type,
    COUNT(*) AS count_collection_days,
    COUNT(*) * 1.0/(SELECT count_collection_days FROM total_collection_days) AS share_collection_days
FROM der.backend_tracking
INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
WHERE
    backend_updated_at BETWEEN DATE '2024-10-30' AND DATE '2025-10-30'
    AND revision_type = 'measurements_tracked'
    AND category = 'collection_method'
    AND consent_health_analytics_revoke_ts IS NULL
    AND consent_usage_analytics_revoke_ts IS NULL
GROUP BY 1
ORDER BY 2 DESC