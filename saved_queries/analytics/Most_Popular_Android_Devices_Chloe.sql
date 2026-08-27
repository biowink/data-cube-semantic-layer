WITH events AS (
    SELECT 
        event_id,
        collector_tstamp,
        dvce_screenwidth,
        dvce_screenheight,
        user_id
    FROM atomic.events
    WHERE collector_tstamp >= '2022-07-01'
)

select
dvce_screenwidth,
dvce_screenheight,
device_manufacturer,
COUNT(distinct user_id) as users

FROM events
LEFT JOIN atomic.com_snowplowanalytics_snowplow_mobile_context_1 AS sp_mobile_ctx
        ON events.event_id = sp_mobile_ctx.root_id
        AND events.collector_tstamp = sp_mobile_ctx.root_tstamp
WHERE sp_mobile_ctx.os_type = 'android'

GROUP BY 1, 2, 3
ORDER BY 4 DESC