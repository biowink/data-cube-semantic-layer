WITH dupes AS (
    SELECT root_id
    FROM der.sorted_events
    WHERE collector_tstamp::DATE BETWEEN '2022-07-13' and '2022-08-01'
    GROUP BY root_id
    HAVING COUNT(1) > 1
),

inaccurate_master_ids AS (
    SELECT root_id, sorted_events.master_id, sorted_events.analytics_id
    FROM der.sorted_events
    INNER JOIN dupes USING (root_id)
    LEFT JOIN (
        SELECT analytics_id, master_id
        FROM der.master_id_device_map
        GROUP BY analytics_id, master_id
    ) AS master_map
        ON sorted_events.analytics_id = master_map.analytics_id
    WHERE collector_tstamp BETWEEN '2022-07-13' and '2022-08-01'
      AND master_map.master_id != sorted_events.master_id
)

-- DELETE
-- FROM der.sorted_events
-- USING inaccurate_master_ids
-- WHERE der.sorted_events.root_id = dupes.root_id
--     AND der.sorted_events.master_id = dupes.master_id
--     AND der.sorted_events.analytics_id = dupes.analytics_id

SELECT 
    count(root_id)
FROM inaccurate_master_ids;