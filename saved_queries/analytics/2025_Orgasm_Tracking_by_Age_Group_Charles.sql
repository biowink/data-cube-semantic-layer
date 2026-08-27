SELECT
    CASE
        WHEN DATE_DIFF('year', birthday, date) < 25 THEN 1
        WHEN DATE_DIFF('year', birthday, date) < 35 THEN 2
        WHEN DATE_DIFF('year', birthday, date) < 45 THEN 3
        ELSE 4
    END AS age_demographic,
    COUNT(DISTINCT analytics_id) AS count_users,
    COUNT(CASE WHEN type = 'orgasm' THEN analytics_id END) AS total_tracking_points,
    COUNT(CASE WHEN type = 'orgasm' THEN analytics_id END) * 1.0/COUNT(DISTINCT analytics_id) AS per_tracker_average,
    COUNT(DISTINCT CASE WHEN type = 'orgasm' THEN analytics_id END) * 1.0/COUNT(DISTINCT analytics_id) AS tracking_rate
FROM der.backend_tracking
INNER JOIN der.users USING (analytics_id)
INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
INNER JOIN der.profiles USING (analytics_id)
WHERE
    backend_tracking.backend_updated_at BETWEEN DATE '2024-11-01' AND DATE '2025-10-31'
--     AND date BETWEEN DATE '2024-11-01' AND DATE '2025-10-31'
    AND revision_type = 'measurements_tracked'
    AND consent_health_analytics_revoke_ts IS NULL
    AND consent_usage_analytics_revoke_ts IS NULL
    AND DATE_DIFF('year', birthday, date) >= 18
    AND account_created_at < DATE '2024-11-01'
    AND category NOT IN ('missing consent')
GROUP BY 1
ORDER BY 1
;