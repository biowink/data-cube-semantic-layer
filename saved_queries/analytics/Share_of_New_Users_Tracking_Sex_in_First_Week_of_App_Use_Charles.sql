WITH first_week_tracking AS (
            SELECT
                sp_users.master_id,
                first_seen,
                COUNT(DISTINCT category) AS count_tracking_categories,
                COUNT(CASE WHEN category = 'sex' THEN 1 END) > 0 AS tracked_sex
            FROM der.sp_users
            LEFT JOIN der.tracking
                    ON sp_users.master_id = tracking.master_id AND
                       backend_created_at::DATE - first_seen::DATE BETWEEN 0 AND 7
            WHERE first_seen BETWEEN '2021-08-02' AND '2022-10-02'
            GROUP BY 1, 2
        )
SELECT DATE_TRUNC('week', first_seen) AS first_seen_week,
       AVG(CASE WHEN tracked_sex THEN 1::FLOAT ELSE 0 END) AS share_tracking_sex
FROM first_week_tracking
WHERE count_tracking_categories >= 1
GROUP BY 1
ORDER BY 1
;