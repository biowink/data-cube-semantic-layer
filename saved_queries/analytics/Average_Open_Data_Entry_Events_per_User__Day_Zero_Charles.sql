WITH day_zero AS (
    SELECT
        sp_users.master_id,
        first_seen,
        first_app_version,
        first_platform,
        COUNT(events.derived_tstamp) AS count_open_data_entry
    FROM der.sp_users
    LEFT JOIN der.events
            ON sp_users.master_id = events.master_id AND mobile_event_name = 'Open Data Entry' AND
               DATEDIFF('day', sp_users.first_seen, derived_tstamp) = 0 AND derived_tstamp >= '2022-11-01'
    WHERE
        first_seen >= '2022-11-01'
    GROUP BY 1, 2, 3, 4
)
SELECT first_seen::DATE,
       first_platform,
       COUNT(DISTINCT master_id) AS count_new_users,
       SUM(count_open_data_entry) AS sum_d0_data_points,
       sum_d0_data_points::FLOAT/count_new_users
FROM day_zero
GROUP BY 1, 2
ORDER BY 1, 2
;