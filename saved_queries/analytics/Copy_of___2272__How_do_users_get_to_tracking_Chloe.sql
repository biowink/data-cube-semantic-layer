WITH raw_events AS (
    SELECT
        master_id,
        session_id,
        derived_tstamp,
        CASE WHEN JSON_EXTRACT_PATH_TEXT(event_properties, 'Navigation Context', FALSE) = 'calendar sheet' THEN 'calendar sheet' else 'bottom bar' END as nav_context
    FROM der.events
    WHERE derived_tstamp >= CURRENT_DATE - '14 days'::INTERVAL
      AND mobile_event_name = 'Open Data Entry'
      AND platform = 'ios'
),

user_level AS (
    SELECT 
        -- session_id,
        master_id,
        COUNT(1) as events,
        COUNT(distinct nav_context) as unique_nav_contexts,
        MAX(CASE WHEN nav_context = 'calendar sheet' THEN 1 else 0 END)::BOOLEAN as used_calendar_sheet
    FROM raw_events
    GROUP BY 1
),

sub as (
SELECT 
    used_calendar_sheet, 
    unique_nav_contexts, 
    --CASE WHEN events < 5 THEN events::varchar else '6+' end as events, 
    count(1) as users
FROM user_level
GROUP BY 1, 2--, 3
ORDER BY 1, 2--, 3
),

total AS (
select sum(users) as total_users
FROM sub
)

select *, users::float/total_users AS share_of_total
FROM sub
JOIN total on 1=1