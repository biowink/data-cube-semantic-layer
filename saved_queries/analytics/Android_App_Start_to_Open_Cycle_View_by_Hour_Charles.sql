WITH session_starts AS (
    SELECT
        sp_device_id,
        platform,
        session_id,
        major_app_version,
        MAX(analytics_id) AS analytics_id,
        MIN(CASE WHEN mobile_event_name = 'App Start' THEN derived_tstamp END) AS app_start_ts,
        MIN(CASE WHEN mobile_event_name = 'Open Cycle View' THEN derived_tstamp END) AS open_cycle_view_ts
    FROM der.events
    WHERE
        derived_tstamp >= CURRENT_DATE - INTERVAL '7' DAY
        AND mobile_event_name IN ('App Start', 'Open Cycle View')
    GROUP BY 1, 2, 3, 4
    HAVING
        MIN(CASE WHEN mobile_event_name = 'Open Cycle View' THEN derived_tstamp END) > MIN(CASE WHEN mobile_event_name = 'App Start' THEN derived_tstamp END)
)
SELECT DATE_TRUNC('hour', app_start_ts) AS hour,
       COUNT(*) AS count_launches,
       APPROX_PERCENTILE(DATE_DIFF('millisecond', app_start_ts, open_cycle_view_ts), 0.20) AS percentile_20,
       APPROX_PERCENTILE(DATE_DIFF('millisecond', app_start_ts, open_cycle_view_ts), 0.50) AS median,
       APPROX_PERCENTILE(DATE_DIFF('millisecond', app_start_ts, open_cycle_view_ts), 0.80) AS percentile_80
FROM session_starts
INNER JOIN der.users USING (analytics_id)
WHERE DATE(app_start_ts) > DATE_ADD('day', 1, DATE(account_created_at)) AND platform = 'android'
GROUP BY 1
ORDER BY 1
;