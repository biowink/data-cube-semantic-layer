WITH dupes AS (
    SELECT root_id
    FROM der.sorted_events
    WHERE collector_tstamp::DATE BETWEEN '2022-07-22':: DATE - INTERVAL '90 days' AND '2022-07-22':: DATE
    GROUP BY root_id
    HAVING COUNT(1) > 1
)

SELECT sorted_events.collector_tstamp, sorted_events.root_id, sorted_events.master_id, sorted_events.analytics_id, country
FROM dupes
JOIN der.sorted_events USING (root_id)
WHERE collector_tstamp::DATE BETWEEN '2022-07-22':: DATE - INTERVAL '90 days' AND '2022-07-22':: DATE