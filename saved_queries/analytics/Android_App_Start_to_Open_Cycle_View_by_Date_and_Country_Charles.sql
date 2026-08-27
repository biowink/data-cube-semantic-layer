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
        derived_tstamp >= CURRENT_DATE - 60
        AND mobile_event_name IN ('App Start', 'Open Cycle View')
        AND country_name = '{{ Country }}'
    GROUP BY 1, 2, 3, 4
    HAVING
        open_cycle_view_ts > app_start_ts
)
SELECT app_start_ts::DATE AS date,
       COUNT(*) AS count_launches,
       percentile_cont(0.20) within group (order by DATEDIFF('millisecond', app_start_ts, open_cycle_view_ts) asc) AS percentile_20,
       percentile_cont(0.50) within group (order by DATEDIFF('millisecond', app_start_ts, open_cycle_view_ts) asc) AS median,
       percentile_cont(0.80) within group (order by DATEDIFF('millisecond', app_start_ts, open_cycle_view_ts) asc) AS percentile_80
FROM session_starts
INNER JOIN der.users USING (analytics_id)
WHERE app_start_ts::DATE > account_created_at::DATE + 1 AND platform = 'android'
GROUP BY 1
ORDER BY 1
;