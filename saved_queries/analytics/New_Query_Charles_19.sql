WITH period_start_events AS (
    SELECT
        session_id,
        platform,
        major_app_version,
        MIN(derived_tstamp) AS min_tstamp,
        COUNT(*) AS count_events
    FROM
        der.events
    WHERE
        derived_tstamp >= DATE '2024-01-01'
        AND major_app_version > 120
        AND mobile_event_name IN ('Select Last Period Start')
    GROUP BY
        1,
        2,
        3
    )
SELECT DATE_TRUNC('month', min_tstamp) AS month,
platform,
AVG(count_events * 1.0) AS avg_events
FROM period_start_events
GROUP BY 1, 2
ORDER BY 1, 2
;