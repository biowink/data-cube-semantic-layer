WITH tracking_combined AS (
    SELECT
        first_seen::DATE AS first_seen_dt,
        sp_users.master_id,
        first_platform,
        COUNT(tracking.master_id) AS count_tracking_points
    FROM der.sp_users
    Left JOIN der.tracking
            ON sp_users.master_id = tracking.master_id AND DATEDIFF('day', first_seen, backend_created_at) = 0 AND backend_created_at >= '2022-11-01'
    WHERE
        first_seen >= '2022-11-01'
    GROUP BY 1, 2, 3
    UNION ALL
    SELECT
        first_seen::DATE AS first_seen_dt,
        sp_users.master_id,
        first_platform,
        COUNT(backend_tracking.user_id) AS count_tracking_points
    FROM der.sp_users
    LEFT JOIN der.backend_tracking
            ON sp_users.user_id = backend_tracking.user_id AND DATEDIFF('day', first_seen, backend_tracking.backend_updated_at) = 0 
            AND backend_tracking.backend_updated_at >= '2022-11-01'
        AND revision_type = 'measurements_tracked'
    WHERE
        first_seen >= '2022-11-01'
    GROUP BY 1, 2, 3
)
SELECT first_seen_dt,
       first_platform,
       SUM(count_tracking_points) AS total_tracking_points,
       COUNT(DISTINCT master_id) AS count_new_users,
       total_tracking_points::FLOAT/count_new_users AS tracking_points_per_user
FROM tracking_combined
GROUP BY 1, 2
ORDER BY 1 DESC, 2
;