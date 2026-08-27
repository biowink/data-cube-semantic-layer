WITH reminder_event_counts AS (
SELECT 
    DATE_TRUNC('day', derived_tstamp) as dt,
    JSON_EXTRACT_PATH_TEXT(event_properties, 'Reminder Category', FALSE) as reminder_category,
    COUNT(DISTINCT master_id) as users
FROM der.events
WHERE derived_tstamp between '2022-06-01' and '2022-07-01'
and mobile_event_name = 'Interact With Reminder'
-- and platform = 'ios'
GROUP BY 1, 2
),

total_event_counts AS (
SELECT 
    DATE_TRUNC('day', derived_tstamp) as dt,
    COUNT(DISTINCT master_id) as total_users
FROM der.events
WHERE derived_tstamp between '2022-06-01' and '2022-07-01'
-- and platform = 'ios'
GROUP BY 1
)

SELECT
    dt,
    MAX(total_users) as total_active_users,
    MAX(CASE WHEN reminder_category = 'use clue' THEN users ELSE NULL END) as use_clue,
    MAX(CASE WHEN reminder_category = 'prediction' THEN users ELSE NULL END) as prediction,
    MAX(CASE WHEN reminder_category = 'other' THEN users ELSE NULL END) as other,
    use_clue::FLOAT/total_active_users as share_use_clue,
    prediction::FLOAT/total_active_users as share_prediction,
    other::FLOAT/total_active_users as share_other

FROM reminder_event_counts r
JOIN total_event_counts t USING(dt)
GROUP BY 1 ORDER BY 1