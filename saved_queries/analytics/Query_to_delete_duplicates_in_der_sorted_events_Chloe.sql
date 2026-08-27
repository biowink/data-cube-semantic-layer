WITH dupes AS (
    SELECT root_id
    FROM der.sorted_events
    WHERE collector_tstamp::DATE BETWEEN '2022-12-26':: DATE - INTERVAL '30 days' AND '2022-12-26':: DATE
    GROUP BY root_id
    HAVING COUNT(1) > 1
),

inaccurate_master_ids AS (
    SELECT sorted_events.root_id, sorted_events.master_id, sorted_events.analytics_id
	FROM dupes
	LEFT JOIN der.sorted_events ON dupes.root_id = sorted_events.root_id
		AND collector_tstamp::DATE BETWEEN '2022-12-26':: DATE - INTERVAL '30 days' AND '2022-12-26':: DATE
    LEFT JOIN der.master_id_device_map ON sorted_events.analytics_id = master_id_device_map.analytics_id
    WHERE master_id_device_map.master_id != sorted_events.master_id
)

DELETE
FROM der.sorted_events
USING inaccurate_master_ids
WHERE der.sorted_events.root_id = inaccurate_master_ids.root_id
    AND der.sorted_events.master_id = inaccurate_master_ids.master_id
    AND der.sorted_events.analytics_id = inaccurate_master_ids.analytics_id

-- SELECT 
--     count(root_id)
-- FROM inaccurate_master_ids;