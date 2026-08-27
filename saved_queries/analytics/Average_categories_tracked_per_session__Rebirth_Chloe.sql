WITH categories_per_session AS (
    SELECT
        CASE WHEN first_seen >= backend_tracking.backend_updated_at - '30 days'::INTERVAL THEN TRUE ELSE FALSE END 
            AS new_user,
        master_id,
        backend_tracking.date,
        COUNT(DISTINCT category) AS unique_categories,
        COUNT(DISTINCT "type") AS unique_options
    
    FROM der.backend_tracking
    JOIN der.sp_users USING (master_id)
    WHERE backend_tracking.backend_updated_at >= CURRENT_DATE - '30 days'::INTERVAL
      AND revision_type != 'legacy_data_migrated'
    GROUP BY 1, 2, 3
)

SELECT 
    new_user,
    AVG(unique_categories::FLOAT) as avg_categories_tracked,
    AVG(unique_options::FLOAT) as avg_options_tracked
FROM categories_per_session
GROUP BY 1