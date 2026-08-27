SELECT
    -- use max to select any value that is not NULL
    MAX(sp_sessions.user_id) AS sp_device_id,
    MAX(events.user_id) AS analytics_id,
    MAX(sp_sessions.session_id) AS session_id,
    MIN(events.derived_tstamp) AS start,
    MAX(sp_sessions.session_index) AS session_index,
    LEAST(MAX(events.derived_tstamp), start + INTERVAL '2 hours') AS session_end,
    DATEDIFF('seconds', start, session_end) AS length_sec,
    MAX(geo_country) AS country_code,
    MAX(geo_region) AS region_code,
    MAX(geo_region_name) AS region_name,
    MAX(geo_city) AS city,
    MAX(br_lang) AS locale,
    MAX(mobile_ctx.birth_year) AS birth_year,
    MAX(sp_mobile_ctx.os_type) AS platform,
    MAX(sp_mobile_ctx.device_model) AS device_model,
    MAX(os_name) AS os_name,
    MAX(sp_mobile_ctx.os_version) AS os_version,
    MAX(sp_mobile_app.version) AS app_version,
    MAX(mobile_ctx.account_state) AS client_account_state,
    MAX(mobile_ctx.birth_control) AS birth_control,
    MAX(mobile_ctx.life_stage) AS life_stage,
    MAX(previous_session_id) AS previous_session_id,
    MIN(events.collector_tstamp) AS min_collector_tstamp,
    MAX(events.collector_tstamp) AS max_collector_tstamp,
    MIN(events.dvce_created_tstamp) AS client_start_tstamp
FROM atomic.events
-- this JOIN filters sessions to client events
JOIN atomic.com_snowplowanalytics_snowplow_client_session_1 AS sp_sessions
    ON events.event_id = sp_sessions.root_id
    AND events.collector_tstamp = sp_sessions.root_tstamp
LEFT JOIN atomic.com_snowplowanalytics_snowplow_mobile_context_1 AS sp_mobile_ctx
    ON events.event_id = sp_mobile_ctx.root_id
    AND events.collector_tstamp = sp_mobile_ctx.root_tstamp
LEFT JOIN atomic.com_snowplowanalytics_mobile_application_1 AS sp_mobile_app
    ON events.event_id = sp_mobile_app.root_id
    AND events.collector_tstamp = sp_mobile_app.root_tstamp
LEFT JOIN atomic.com_helloclue_mobile_events_1 AS mobile_events
    ON events.event_id = mobile_events.root_id
    AND events.collector_tstamp = mobile_events.root_tstamp
LEFT JOIN atomic.com_helloclue_mobile_user_2 AS mobile_ctx
    ON events.event_id = mobile_ctx.root_id
    AND events.collector_tstamp = mobile_ctx.root_tstamp
WHERE
    collector_tstamp >= '2022-03-14' :: TIMESTAMP - INTERVAL '15 minutes' AND
    -- we process 1 hour worth of data with a 15 minutes lag so that users who start
    -- using Clue at midnight still have 15 minutes to create their account
    -- here we also include the last 15 minutes to check for the analytics_id
    -- after account creation
    collector_tstamp < '2022-03-14' :: TIMESTAMP + INTERVAL '30 minutes'
    AND mobile_events.event_name NOT IN ('Did Get User Details',
                                            'Tried To Get User Details',
                                            'Show Reminder',
                                            'Interact With Reminder',
                                            'Notification State Changed',
                                            'Reminder Shown Without Interaction',
                                            'Magic Box Shown',
                                            'Open Connections',
                                            'Daily Backup Job',
                                            'Daily Backup Job Scheduled',
                                            'Open Content Tab',
                                            'CBC Cycles Fetched',
                                            'Sync Started',
                                            'Sync Ended',
                                            'CBC Availability Info',
                                            'Screen Reader Status',
                                            'Cbc Availability Info',
                                            'Tried To Get Profile',
                                            'Did Get Profile',
                                            'Tried To Update Profile',
                                            'Did Update Profile')
GROUP BY sp_sessions.session_id