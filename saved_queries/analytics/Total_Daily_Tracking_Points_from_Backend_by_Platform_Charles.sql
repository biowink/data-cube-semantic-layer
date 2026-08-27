WITH tracking_points AS (
    SELECT
        tracking.backend_updated_at::DATE AS date,
        first_platform,
        COUNT(*) AS count_tracking_points
    FROM der.tracking
    LEFT JOIN der.sp_users
            USING (master_id)
    WHERE
        tracking.backend_updated_at >= '2021-11-01'
    GROUP BY 1, 2
    UNION ALL
    SELECT
        backend_tracking.backend_updated_at::DATE AS date,
        first_platform,
        COUNT(*) AS count_tracking_points
    FROM der.backend_tracking
    LEFT JOIN der.sp_users
            USING (master_id)
    WHERE
        backend_tracking.backend_updated_at >= '2022-01-01'
        AND revision_type = 'measurements_tracked'
    GROUP BY 1, 2
)
SELECT DATE_TRUNC('week', date) AS week,
       first_platform AS platform,
       SUM(count_tracking_points) AS total_tracking_points
FROM tracking_points
GROUP BY 1, 2
ORDER BY 1, 2
;