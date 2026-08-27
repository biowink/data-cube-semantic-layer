WITH indices AS (
    SELECT ROW_NUMBER() OVER (ORDER BY date) - 1 AS index FROM static.calendar LIMIT 40
    )
SELECT experiment_id,
       variation_id,
       index,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Daily Check In' THEN events.analytics_id END) AS count_activity,
       count_activity::FLOAT/count_users AS activity_rate
FROM temp.daily_checking_users_20240522 users
CROSS JOIN indices
LEFT JOIN der.events ON users.analytics_id = events.analytics_id
                                      AND events.derived_tstamp > entered_experiment_ts
                                        AND events.derived_tstamp >= '2024-04-23'
                                        AND mobile_event_name IN ('Open Daily Check In', 'Open Data Entry', 'Open Cycle View')
                                        AND DATEDIFF('day', entered_experiment_ts, derived_tstamp) = index
WHERE index < DATEDIFF('day', entered_experiment_ts, '2024-05-22') AND variation_id = '1'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;