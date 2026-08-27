WITH recent_users AS (
    SELECT
        sp_users.master_id,
        SUM(CASE WHEN category = 'period' THEN 1 END) AS period_tracking,
        COUNT(DISTINCT category) AS categories_tracked
    FROM der.sp_users
    LEFT JOIN der.backend_tracking
            ON sp_users.master_id = backend_tracking.master_id AND revision_type = 'measurements_tracked'
            AND backend_tracking.backend_updated_at >= CURRENT_DATE - 60
    WHERE
        first_seen < CURRENT_DATE - 60
        AND last_seen >= CURRENT_DATE - 60
        AND last_platform = 'ios'
        AND SPLIT_PART(last_app_version, '.', 1)::INT >= 100
    GROUP BY 1
    HAVING period_tracking > 0
)
SELECT categories_tracked,
       COUNT(*)::FLOAT/(SELECT COUNT(*) FROM recent_users) AS share_users
FROM recent_users
GROUP BY 1
ORDER BY 1
;