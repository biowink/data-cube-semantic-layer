SELECT last_platform,
        backend_tracking.backend_updated_at::DATE AS backend_updated_dt,
       COUNT(*) AS count_tracking_points,
       COUNT(CASE WHEN backend_tracking.master_id IS NULL THEN 1 END) AS count_tracking_points_missing_master_id,
       count_tracking_points_missing_master_id::FLOAT/count_tracking_points AS share_tracking_points_missing_master_id
FROM der.backend_tracking
LEFT JOIN der.sp_users
    USING(analytics_id)
WHERE backend_tracking.backend_updated_at >= '2023-01-01'
GROUP BY 1,2
ORDER BY 2, 1 DESC
;