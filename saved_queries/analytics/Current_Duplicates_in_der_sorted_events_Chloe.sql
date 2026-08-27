WITH dupes AS (
    SELECT root_id
    FROM der.sorted_events
    WHERE collector_tstamp::DATE BETWEEN '2022-07-13' and '2022-08-01'
    GROUP BY root_id
    HAVING COUNT(1) > 1
)

SELECT COUNT(root_id) FROM dupes;