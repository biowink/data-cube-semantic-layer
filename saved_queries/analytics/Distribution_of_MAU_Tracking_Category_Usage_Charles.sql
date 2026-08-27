WITH categories AS (
    SELECT
        sp_users.master_id,
        COUNT(DISTINCT tracking.category) AS count_tracking_category
    FROM der.sp_users
    LEFT JOIN der.tracking
            ON sp_users.master_id = tracking.master_id AND
               last_seen::DATE - tracking.backend_created_at::DATE BETWEEN 0 AND 30
    WHERE
        NOT is_test_user
        AND last_seen >= CURRENT_DATE - 30
    GROUP BY 1
)
SELECT LEAST(count_tracking_category, 10) AS count_tracking_category,
       COUNT(*)::FLOAT/(SELECT COUNT(*) FROM categories) AS share_users
FROM categories
GROUP BY 1
ORDER BY 1
;