 WITH raw_output AS (
 SELECT DISTINCT
        NVL(map.master_id, backend_master_ids.master_id),
        sp_session.session_index,
        sp_session.user_id AS sp_device_id,
        events.user_id AS analytics_id,
        events.derived_tstamp,
        events.collector_tstamp,
        events.event_name::VARCHAR(255) AS schema_name,
        mobile_e.event_name::VARCHAR(255) AS mobile_event_name,
        backend_subs_events.event_name::VARCHAR(255) AS backend_subscription_event_name,
        -- we've removed backend offered products from the pipeline, so after 09/2022 this field will always be null
        NULL as backend_offered_products,
        mobile_e.event_properties::VARCHAR(511),
        sp_mobile_ctx.os_type AS platform,
        countries.country_name AS country,
        sp_mobile_app.version AS app_version,
        event_id AS root_id,
        '{{ ts }}' :: TIMESTAMP,
        SYSDATE
    FROM atomic.events
    LEFT JOIN atomic.com_snowplowanalytics_snowplow_client_session_1 AS sp_session
        ON events.event_id = sp_session.root_id
        AND events.collector_tstamp = sp_session.root_tstamp
    LEFT JOIN atomic.com_helloclue_mobile_events_1 AS mobile_e
        ON events.event_id = mobile_e.root_id
        AND events.collector_tstamp = mobile_e.root_tstamp
    LEFT JOIN atomic.com_helloclue_backend_subscription_events_1 AS backend_subs_events
        ON events.event_id = backend_subs_events.root_id
        AND events.collector_tstamp = backend_subs_events.root_tstamp
    LEFT JOIN atomic.com_snowplowanalytics_snowplow_mobile_context_1 AS sp_mobile_ctx
        ON events.event_id = sp_mobile_ctx.root_id
        AND events.collector_tstamp = sp_mobile_ctx.root_tstamp
    LEFT JOIN atomic.com_snowplowanalytics_mobile_application_1 AS sp_mobile_app
        ON events.event_id = sp_mobile_app.root_id
        AND events.collector_tstamp = sp_mobile_app.root_tstamp
    LEFT JOIN der.master_id_device_map AS map
        ON sp_session.user_id = map.sp_device_id
    LEFT JOIN static.countries
        ON events.geo_country = countries.iso_alpha_2
    LEFT JOIN (
        SELECT analytics_id, master_id
        FROM der.master_id_device_map
        WHERE analytics_id IS NOT NULL
        GROUP BY analytics_id, master_id
    ) AS backend_master_ids
        ON events.user_id = backend_master_ids.analytics_id
    -- LEFT JOIN (
    --     SELECT root_id
    --     FROM der.sorted_events
    --     WHERE collector_tstamp >= '{{ ts }}' :: TIMESTAMP - INTERVAL '15 minutes'
    --       AND collector_tstamp < '{{ ts }}' :: TIMESTAMP + INTERVAL '45 minutes'
    -- ) AS existing
    --     ON events.event_id = existing.root_id
    WHERE -- existing.root_id IS NULL
      -- AND 
      events.event_name::VARCHAR(255) != 'backend_offered_products'
      AND events.collector_tstamp >= '{{ ts }}' :: TIMESTAMP - INTERVAL '15 minutes'
      AND events.collector_tstamp < '{{ ts }}' :: TIMESTAMP + INTERVAL '45 minutes'
      AND events.derived_tstamp > events.collector_tstamp - INTERVAL '30 days'
)

SELECT schema_name, COUNT(root_id) AS events
FROM raw_output
GROUP BY schema_name
ORDER BY schema_name
