SELECT DATE_TRUNC('week', backend_tracking.backend_updated_at) AS date,
    COUNT(DISTINCT analytics_id) AS count_users,
    COUNT(DISTINCT CASE WHEN type = 'period_cramps' THEN analytics_id END) * 1.0/
        COUNT(DISTINCT analytics_id) AS share_tracking_cramps
FROM der.backend_tracking
INNER JOIN der.users USING (analytics_id)
WHERE revision_type = 'measurements_tracked'
    AND backend_tracking.backend_updated_at BETWEEN DATE '2023-09-30' AND DATE '2025-02-17'
    AND category != 'missing consent'
    AND DATE_DIFF('day', account_created_at, backend_tracking.backend_updated_at) > 365
GROUP BY 1
ORDER BY 1
;