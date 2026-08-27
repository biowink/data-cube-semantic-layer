WITH session_activities AS (
SELECT
    session_id,
    mobile_event_name,
    MIN(HOUR( DATE_TRUNC('hour', at_timezone(derived_tstamp, timezone)))) AS app_hour
FROM der.events
WHERE derived_tstamp >= CURRENT_DATE - INTERVAL '30' DAY
AND mobile_event_name IN ('Show Cramps Prediction Screen', 'Open Cycle View')
AND product_tier = 'clue plus'
AND timezone IS NOT NULL
GROUP BY 1, 2
)
SELECT
    mobile_event_name,
    app_hour,
    COUNT(*) * 1.0/total_sessions AS count_users
FROM session_activities
INNER JOIN (SELECT mobile_event_name, COUNT(*) AS total_sessions FROM session_activities GROUP BY 1) USING (mobile_event_name)
GROUP BY 1, 2, total_sessions
ORDER BY 1, 2