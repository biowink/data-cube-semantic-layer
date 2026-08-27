WITH period_trackers AS (
    SELECT
        session_id,
        MIN(derived_tstamp) AS session_start,
        MAX(derived_tstamp) AS session_end,
        DATEDIFF('second', session_start, session_end) AS session_length_sec,
        MIN(CASE
                WHEN mobile_event_name = 'Open Option Modal' THEN derived_tstamp
            END) AS open_option_modal_ts,
        MIN(CASE
                WHEN mobile_event_name = 'Exit Option Modal' THEN derived_tstamp
            END) AS exit_option_nonperiod_ts,
        MIN(CASE
                WHEN mobile_event_name = 'Exit Option Modal' AND
                     JSON_EXTRACT_PATH_TEXT(event_properties, 'Category') = 'period' THEN derived_tstamp
            END) AS exit_option_period_ts,
        MIN(CASE
                WHEN mobile_event_name = 'Exit Data Entry' AND
                     JSON_EXTRACT_PATH_TEXT(event_properties, 'Number of Added Data Points') != '' THEN derived_tstamp
            END) AS exit_data_entry_ts,
        DATEDIFF('second', session_start, open_option_modal_ts) AS time_to_tracking_sec
    FROM der.events
    INNER JOIN der.sp_users
            USING (master_id)
    WHERE
        derived_tstamp >= CURRENT_DATE - 7
        AND platform = 'ios'
        AND DATEDIFF('day', first_seen, derived_tstamp) > 30
        AND mode = 'period tracking'
        AND major_app_version > 100
        AND mobile_event_name NOT IN
            ('Did Get User Details', 'Tried To Get User Details', 'Show Reminder', 'Interact With Reminder',
             'Notification State Changed', 'Reminder Shown Without Interaction', 'Magic Box Shown', 'Open Connections',
             'Daily Backup Job', 'Daily Backup Job Scheduled', 'CBC Cycles Fetched', 'Sync Started', 'Sync Ended',
             'CBC Availability Info', 'Screen Reader Status', 'Cbc Availability Info', 'Tried To Get Profile',
             'Did Get Profile', 'Tried To Update Profile', 'Did Update Profile')
    GROUP BY 1
    HAVING exit_option_nonperiod_ts IS NOT NULL AND exit_data_entry_ts IS NOT NULL AND exit_option_period_ts IS NULL
),
    pdt AS (
        SELECT
            time_to_tracking_sec,
                COUNT(*)::FLOAT / (
                SELECT COUNT(*)
                FROM period_trackers
            ) AS freq
        FROM period_trackers
        GROUP BY 1
    )
SELECT time_to_tracking_sec,
       SUM(freq) OVER (ORDER BY time_to_tracking_sec ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_dens
FROM pdt
ORDER BY 1
LIMIT 300
;