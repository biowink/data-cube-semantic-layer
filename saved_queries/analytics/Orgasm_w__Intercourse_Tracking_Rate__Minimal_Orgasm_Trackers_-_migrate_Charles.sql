WITh sex_trackers AS (
SELECT
    analytics_id,
    date,
    SUM(CASE WHEN type IN ('protected', 'unprotected', 'withdrawal') THEN 1 ElSE 0 END) AS sex_tracked,
    SUM(CASE WHEN type = 'orgasm' THEN 1 ElSE 0 END) AS orgasm_tracked
FROM der.backend_tracking
INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
WHERE
    backend_tracking.backend_updated_at BETWEEN DATE '2024-11-01' AND DATE '2025-11-01'
--     AND date BETWEEN DATE '2024-11-01' AND DATE '2025-10-31'
    AND revision_type = 'measurements_tracked'
    AND consent_health_analytics_revoke_ts IS NULL
    AND consent_usage_analytics_revoke_ts IS NULL
    AND category IN ('sex_life')
GROUP BY 1, 2
)
SELECT
    AVG(CASE WHEN orgasm_tracked > 0 THEN 1.0 ELSE 0 END) AS orgasm_sex_tracking_rate
FROM sex_trackers
WHERE sex_tracked > 0
    AND analytics_id IN (SELECT analytics_id FROM sex_trackers WHERE orgasm_tracked > 0 AND sex_tracked > 0)
;