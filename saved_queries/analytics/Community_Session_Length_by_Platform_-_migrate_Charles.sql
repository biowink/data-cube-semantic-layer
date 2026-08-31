WITH ordered_events AS (
    SELECT
        analytics_id,
        platform,
        mobile_event_name,
        derived_tstamp,
        -- Get the name and timestamp of the next event for the same user
        LEAD(mobile_event_name) OVER (
            PARTITION BY analytics_id
            ORDER BY derived_tstamp
        ) AS next_event_name,
        LEAD(derived_tstamp) OVER (
            PARTITION BY analytics_id
            ORDER BY derived_tstamp
        ) AS next_tstamp
    FROM der.events
    WHERE derived_tstamp >= DATE '2026-07-24'
      AND mobile_event_name IN ('Session Started', 'Session Stopped', 'Octopus Session Started', 'Octopus Session Stopped')
),
    session_lengths AS (
SELECT
    analytics_id,
    platform,
    derived_tstamp AS session_start_time,
    next_tstamp AS session_end_time,
    date_diff('second', derived_tstamp, next_tstamp) AS session_duration_seconds
FROM ordered_events
WHERE mobile_event_name IN ('Session Started', 'Octopus Session Started')
  AND next_event_name IN ('Session Stopped', 'Octopus Session Stopped')
)
SELECT
    platform,
    COUNT(*) AS count_sessions,
    APPROX_PERCENTILE(session_duration_seconds, 0.5) AS median_session_length,
    AVG(session_duration_seconds) AS average_session_length
FROM session_lengths
GROUP BY 1
ORDER BY 1
;