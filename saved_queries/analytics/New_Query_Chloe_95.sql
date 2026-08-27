WITH cts AS (
    SELECT
        analytics_id,
        count(master_id) as ct
    FROM der.master_id_device_map
    GROUP BY 1
)

SELECT 
    ct as ct_of_master_ids,
    COUNT(analytics_id) as analytics_ids
FROM cts
GROUP BY 1
ORDER BY 1