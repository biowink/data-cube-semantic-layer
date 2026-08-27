WITH session_length_enriched AS (
    SELECT *,
        LEAST(last_event_ts, first_event_ts + INTERVAL '2 Hours') AS session_end,
        DATEDIFF('seconds', first_event_ts, session_end) AS length_sec
    FROM temp.session_length_refactored
    WHERE ((first_event_ts::DATE BETWEEN '2022-11-10' AND '2022-11-16')
       OR (first_event_ts::DATE BETWEEN '2023-01-10' AND '2023-01-16'))
        AND major_app_version IN (72, 101)
),
    normalization AS (
        SELECT is_rebirth,
               COUNT(*) AS total_sessions
        FROM session_length_enriched
        WHERE length_sec >= 600
        GROUP BY 1
    )
SELECT is_rebirth,
       last_event_name,
       COUNT(*)::FLOAT/total_sessions AS share_sessions,
       AVG(count_events::FLOAT) AS avg_events_in_session,
       AVG(length_sec::FLOAT) AS avg_length_sec
FROM session_length_enriched
LEFT JOIN normalization USING (is_rebirth)
WHERE length_sec >= 600
GROUP BY 1, 2, total_sessions
ORDER BY 3 DESC
;