WITH atomic_events AS (
    SELECT
        -- use max to select any value that is not NULL
        FIRST_VALUE(sp_sessions.user_id) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS sp_device_id,
        FIRST_VALUE(events.user_id) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS analytics_id,
        --MAX(sp_sessions.session_id) AS session_id, -- this does not matter because we group by sp_sessions.session_id at the end
        sp_sessions.session_id,
        LAST_VALUE(events.derived_tstamp) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS start,
        FIRST_VALUE(sp_sessions.session_index) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_index,
        LEAST(FIRST_VALUE(events.derived_tstamp) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
             start + INTERVAL '2 hours') AS session_end,
        DATEDIFF('seconds', start, session_end) AS length_sec,
        FIRST_VALUE(geo_country) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS country_code,
        FIRST_VALUE(geo_region) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS region_code,
        FIRST_VALUE(geo_region_name) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS region_name,
        FIRST_VALUE(geo_city) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS city,
        FIRST_VALUE(br_lang) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS locale,
        FIRST_VALUE(mobile_ctx.birth_year) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS birth_year,
        FIRST_VALUE(sp_mobile_ctx.os_type) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS platform,
        FIRST_VALUE(sp_mobile_ctx.device_model) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS device_model,
        FIRST_VALUE(os_name) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS os_name,
        FIRST_VALUE(sp_mobile_ctx.os_version) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS os_version,
        FIRST_VALUE(sp_mobile_app.version) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS app_version,
        FIRST_VALUE(mobile_ctx.account_state) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS client_account_state,
        FIRST_VALUE(mobile_ctx.birth_control) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS birth_control,
        FIRST_VALUE(mobile_ctx.life_stage) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS life_stage,
        FIRST_VALUE(previous_session_id) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS previous_session_id,
        LAST_VALUE(events.collector_tstamp) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS min_collector_tstamp,
        FIRST_VALUE(events.collector_tstamp) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_collector_tstamp,
        LAST_VALUE(events.dvce_created_tstamp) OVER (PARTITION BY sp_sessions.session_id 
                                               ORDER BY events.derived_tstamp DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS client_start_tstamp,
        RANK() OVER (PARTITION BY sp_sessions.session_id ORDER BY events.derived_tstamp DESC) as rank
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
)

SELECT *
FROM atomic_events
WHERE rank=1