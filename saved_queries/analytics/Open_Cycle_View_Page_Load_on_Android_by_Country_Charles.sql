WITH session_starts AS (
    SELECT
        sp_device_id,
        platform,
        session_id,
        major_app_version >= 150 AS post_improvements,
        country_name,
        MAX(analytics_id) AS analytics_id,
        MIN(CASE WHEN mobile_event_name = 'App Start' THEN derived_tstamp END) AS app_start_ts,
        MIN(CASE WHEN mobile_event_name = 'Open Cycle View' THEN derived_tstamp END) AS open_cycle_view_ts
    FROM der.events
    WHERE
          derived_tstamp >= CURRENT_DATE - 90
      AND mobile_event_name IN ('App Start', 'Open Cycle View')
    GROUP BY 1, 2, 3, 4, 5
    HAVING
        open_cycle_view_ts > app_start_ts
    )
SELECT
    country_name,
    post_improvements,
    COUNT(*) AS count_launches,
    PERCENTILE_CONT(0.50)
    WITHIN GROUP (ORDER BY DATEDIFF('millisecond', app_start_ts, open_cycle_view_ts) ASC) AS median
FROM session_starts
INNER JOIN der.users USING (analytics_id)
WHERE
      app_start_ts::DATE > account_created_at::DATE + 1
  AND platform = 'android'
  AND country_name IN ('United States', 'Germany', 'France', 'Mexico', 'Brazil', 'United Kingdom', 'Australia')
GROUP BY 1, 2
HAVING
    count_launches > 1000
ORDER BY 1, 2