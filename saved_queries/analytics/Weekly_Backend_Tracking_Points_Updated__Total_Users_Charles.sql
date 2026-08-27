
WITH combined_tracking AS (
    SELECT
        DATE_TRUNC('week', backend_created_at::DATE) AS week,
        COUNT(*) AS count_tracking_points
    FROM der.tracking
    WHERE
        backend_created_at >= '2022-11-01'
    GROUP BY 1
    UNION ALL
    SELECT
        DATE_TRUNC('week', backend_updated_at::DATE) AS week,
        COUNT(*) AS count_tracking_points
    FROM der.backend_tracking
    WHERE
        backend_updated_at >= '2022-11-01'
        AND revision_type = 'measurements_tracked'
    GROUP BY 1
)
SELECT week,
       SUM(count_tracking_points) AS total_tracking_points
FROM combined_tracking
GROUP BY 1
ORDER BY 1
;