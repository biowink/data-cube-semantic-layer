WITH tracking_users AS (
    SELECT
        derived_tstamp,
        master_id,
        session_id,
        mobile_event_name,
        platform,
        -- ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY derived_tstamp)
        LEAD(mobile_event_name) OVER (PARTITION BY session_id ORDER BY derived_tstamp) as next_event,
        LEAD(mobile_event_name, 2) OVER (PARTITION BY session_id ORDER BY derived_tstamp) as next_next_event,
        -- LAG(mobile_event_name) OVER (PARTITION BY session_id ORDER BY derived_tstamp) as last_event
        DATEDIFF('day', first_seen, derived_tstamp) as user_age
    FROM der.events
    JOIN der.sp_users USING (master_id)
    WHERE derived_tstamp >= '2023-05-13'
    AND mobile_event_name IN ('Exit Option Modal', 'Open Option Modal',
                              'Exit Data Entry', 'Exit Data Entry Without Saving', 'Open Data Entry', 
                              'Exit Category Selection Screen', 'Open Category Selection Screen',
                              'Select Return to Today', 'Show Error Screen')
),
-- ,

-- last_exit_option_modal AS (
--     SELECT
--         session_id,
--         MAX(derived_tstamp) as last_tstamp
--     FROM tracking_users
--     WHERE mobile_event_name = 'Exit Option Modal'
--     GROUP BY 1
-- )

counts AS (
SELECT
    platform,
    CASE WHEN user_age = 0 THEN 'D0'
         WHEN user_age BETWEEN 1 and 30 THEN 'M1'
         ELSE 'D31+'
         END as user_age,
    mobile_event_name,
    next_event,
    next_next_event,
    COUNT(session_id) as events
    
FROM tracking_users
-- JOIN last_exit_option_modal USING(session_id)
-- WHERE last_tstamp = derived_tstamp
WHERE mobile_event_name = 'Exit Option Modal'
  AND next_event IN ('Exit Data Entry', 'Exit Data Entry Without Saving')
group by 1, 2, 3, 4, 5 order by 1, 2, 3, 6 desc
),

totals AS (
    SELECT platform, user_age, sum(events) as total_events
    FROM counts
    GROUP BY 1, 2
)

SELECT counts.*, events::float/total_events as share_of_total
FROM counts
JOIN totals USING (platform, user_age)
order by 1, 2, 3, 6 desc
