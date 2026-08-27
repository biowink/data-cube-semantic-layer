WITH categories_per_session AS (
    SELECT
        DATE_TRUNC('month', tracking.backend_created_at) as month_tracked,
        CASE WHEN first_seen >= tracking.backend_created_at - '30 days'::INTERVAL THEN TRUE ELSE FALSE END 
            AS new_user,
        master_id,
        tracking.date,
        COUNT(DISTINCT category) AS unique_categories,
        COUNT(DISTINCT "type") AS unique_options
    
    FROM der.tracking
    JOIN der.sp_users USING (master_id)
    WHERE tracking.backend_created_at BETWEEN '2021-01-01' AND '2022-12-01'
      GROUP BY 1, 2, 3, 4
)

SELECT 
    month_tracked,
    new_user,
    AVG(unique_categories::FLOAT) as avg_categories_tracked,
    AVG(unique_options::FLOAT) as avg_options_tracked
FROM categories_per_session
GROUP BY 1, 2
ORDER BY 1, 2