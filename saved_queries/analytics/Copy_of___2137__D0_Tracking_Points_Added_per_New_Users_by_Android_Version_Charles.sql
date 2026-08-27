WITH day_zero AS (
    SELECT
        sp_users.master_id,
        first_seen,
        first_app_version,
        JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') AS added_data_points_raw,
        CASE WHEN NVL(added_data_points_raw, '') != '' THEN CAST(added_data_points_raw AS INT) END AS added_data_points
    FROM der.sp_users
    LEFT JOIN der.events
            ON sp_users.master_id = events.master_id AND mobile_event_name = 'Exit Data Entry' AND
               DATEDIFF('day', sp_users.first_seen, derived_tstamp) = 0 AND derived_tstamp >= '2023-04-01'
    WHERE
        first_seen >= '2023-04-01' AND first_platform = 'android'
)
SELECT first_app_version,
       COUNT(DISTINCT master_id) AS count_new_users,
       SUM(added_data_points) AS sum_d0_data_points,
       sum_d0_data_points::FLOAT/count_new_users AS avg_d0_tracking_points
FROM day_zero
GROUP BY 1
HAVING count_new_users > 5000
ORDER BY 1
;