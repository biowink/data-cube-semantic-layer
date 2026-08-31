SELECT
    MONTH(backend_updated_at) AS month,
    CASE
    WHEN latitude > 0 THEN 'Northern Hemisphere' 
    ELSE 'Southern Hemisphere' END AS hemisphere,
    AVG(CASE WHEN type IN ('woke_up_tired') THEN 1.0 ELSE 0 END) AS share_wake_up_tired
FROM der.backend_tracking
INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
INNER JOIN user_metrics.user_last_session_attributes USING (analytics_id)
WHERE
    backend_updated_at BETWEEN DATE '2024-11-01' AND DATE '2025-11-01'
    AND revision_type = 'measurements_tracked'
    AND consent_health_analytics_revoke_ts IS NULL
    AND consent_usage_analytics_revoke_ts IS NULL
    AND category = 'sleep_quality'
    AND ABS(latitude) > 23
GROUP BY 1, 2
ORDER BY 1, 2
;