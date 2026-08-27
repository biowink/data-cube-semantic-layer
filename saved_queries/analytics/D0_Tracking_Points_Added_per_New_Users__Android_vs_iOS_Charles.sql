WITH day_zero AS (
    SELECT
        sp_users.master_id,
        first_seen,
        first_app_version,
        first_platform,
        JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') AS added_data_points_raw,
        CASE WHEN NVL(added_data_points_raw, '') != '' THEN CAST(added_data_points_raw AS INT) END AS added_data_points
    FROM der.sp_users
    LEFT JOIN der.events
            ON sp_users.master_id = events.master_id AND mobile_event_name = 'Exit Data Entry' AND
               DATEDIFF('day', sp_users.first_seen, derived_tstamp) = 0 AND derived_tstamp >= '{{min_date}}'
    WHERE
        first_seen >= '{{min_date}}'
)
SELECT first_seen::DATE,
       first_platform,
       COUNT(DISTINCT master_id) AS count_new_users,
       SUM(added_data_points) AS sum_d0_data_points,
       sum_d0_data_points::FLOAT/count_new_users
FROM day_zero
GROUP BY 1, 2
ORDER BY 1, 2
;