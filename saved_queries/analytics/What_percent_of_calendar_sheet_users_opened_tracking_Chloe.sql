WITH calendar_sheet_opens AS (
    SELECT
        master_id,
        session_id,
        derived_tstamp,
        mobile_event_name
    FROM der.events
    WHERE derived_tstamp >= CURRENT_DATE - '14 days'::INTERVAL
      AND mobile_event_name = 'Show Calendar Sheet'
      AND platform = 'ios'
),

tracking_opens AS (
    SELECT
        master_id,
        session_id,
        derived_tstamp,
        mobile_event_name
    FROM der.events
    WHERE derived_tstamp >= CURRENT_DATE - '14 days'::INTERVAL
      AND mobile_event_name = 'Open Data Entry'
      AND JSON_EXTRACT_PATH_TEXT(event_properties, 'Navigation Context', FALSE) = 'calendar sheet'
      AND platform = 'ios'
),

session_level AS (
    SELECT
        c.master_id,
        c.session_id,
        c.derived_tstamp,
        MAX(CASE WHEN t.mobile_event_name is NOT NULL then 1 ELSE 0 END) AS opened_tracking
    FROM calendar_sheet_opens c
    LEFT JOIN tracking_opens t
        ON (c.session_id = t.session_id 
           AND c.master_id = t.master_id
           AND t.derived_tstamp BETWEEN c.derived_tstamp AND c.derived_tstamp + '1 hour'::INTERVAL)
    GROUP BY 1, 2, 3
)

SELECT 
    COUNT(1) as events,
    COUNT(distinct session_id) as sessions,
    COUNT(distinct master_id) as users,
    COUNT(CASE WHEN opened_tracking = 1 THEN 1 else NULL END) as events_opened_tracking,
    COUNT(distinct CASE WHEN opened_tracking = 1 THEN session_id else NULL END) as sessions_opened_tracking,
    COUNT(distinct CASE WHEN opened_tracking = 1 THEN master_id else NULL END) as users_opened_tracking,
    events_opened_tracking::FLOAT/events as share_events_opened_tracking,
    sessions_opened_tracking::FLOAT/sessions as share_sessions_opened_tracking,
    users_opened_tracking::FLOAT/users as share_users_opened_tracking,
    events::float/sessions as events_per_session,
    sessions::float/users as sessions_per_user
FROM session_level
