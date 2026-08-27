WITH dupes AS (
    SELECT root_id, min(derived_tstamp) as mint, max(derived_tstamp) as maxt
    FROM der.sorted_events
    WHERE collector_tstamp::DATE BETWEEN '2022-09-06'
                                          AND '2022-09-11':: DATE
    GROUP BY root_id
    HAVING COUNT(1) > 1
)


SELECT * FROM der.sorted_events
WHERE derived_tstamp::DATE BETWEEN '2022-09-06'
                                          AND '2022-09-11':: DATE
    AND root_id IN (select root_id from dupes)
ORDER BY root_id, derived_tstamp