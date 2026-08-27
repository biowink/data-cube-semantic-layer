-- WITH cbc_users_raw AS (
--           SELECT
--             master_id,
--             analytics_id,
--             user_id,
--             min(dot_cycle_statistics.cycle_start) AS first_cbc_cycle_start,
--             max(dot_cycle_statistics.cycle_start) AS last_cbc_cycle_start,
--             min(dot_cycle_statistics.sync_timestamp) As first_algo_run
--           FROM
--             der.dot_cycle_statistics
--           GROUP BY
--             master_id,
--             analytics_id,
--             user_id
--           ),

--           cbc_users_enriched AS (
--           SELECT
--             cbc_users_raw.*,
--             min(cycles.cycle_start) as first_non_cbc_cycle_start
--           FROM
--             cbc_users_raw
--             LEFT JOIN der.cycles
--               ON cycles.cycle_start > '2021-10-18'
--               AND cbc_users_raw.user_id = cycles.user_id
--               AND cycles.cycle_start > cbc_users_raw.last_cbc_cycle_start
--               AND NOT cycles.cycle_predicted AND cycles.cycle_is_valid
--           GROUP BY
--             cbc_users_raw.master_id,
--             cbc_users_raw.analytics_id,
--             cbc_users_raw.user_id,
--             cbc_users_raw.first_cbc_cycle_start,
--             cbc_users_raw.last_cbc_cycle_start,
--             cbc_users_raw.first_algo_run
--           )

--           SELECT
--             sp_users.master_id,
--             sp_users.analytics_id,
--             sp_users.user_id,
--             cbc_users.first_cbc_cycle_start,
--             cbc_users.last_cbc_cycle_start,
--             cbc_users.first_algo_run,
--             sorted_events.collector_tstamp
--           FROM
--             cbc_users_enriched AS cbc_users
--             JOIN der.sp_users
--               ON sp_users.user_id = cbc_users.user_id
--             JOIN der.sorted_events
--               ON sorted_events.collector_tstamp > '2021-10-18'
--               AND sorted_events.master_id = sp_users.master_id
--               AND sorted_events.collector_tstamp >= dateadd(day, 5, cbc_users.first_algo_run)
--               AND sorted_events.collector_tstamp < nvl(cbc_users.first_non_cbc_cycle_start, '9999-01-01')
--             WHERE
--               sorted_events.mobile_event_name = 'Change Mode'
--               AND json_extract_path_text(event_properties, 'New Mode') = 'pregnancy'
--               AND (sp_users.is_test_user is NULL OR sp_users.is_test_user is FALSE)
-- ;

WITH cbc_users_raw AS (
    SELECT
        master_id,
        analytics_id,
        user_id,
        MIN(dot_cycle_statistics.cycle_start) AS first_cbc_cycle_start,
        MAX(dot_cycle_statistics.cycle_start) AS last_cbc_cycle_start,
        MIN(dot_cycle_statistics.sync_timestamp) AS first_algo_run
    FROM der.dot_cycle_statistics
    GROUP BY master_id, analytics_id, user_id
),

    cbc_users_enriched AS (
        SELECT
            cbc_users_raw.*,
            MIN(cycles.cycle_start) AS first_non_cbc_cycle_start
        FROM cbc_users_raw
        LEFT JOIN der.cycles
                ON cycles.cycle_start > '2021-10-18'
                       AND cbc_users_raw.user_id = cycles.user_id
                       AND cycles.cycle_start > cbc_users_raw.last_cbc_cycle_start
                       AND NOT cycles.cycle_predicted
                       AND cycles.cycle_is_valid
        GROUP BY
            cbc_users_raw.master_id,
            cbc_users_raw.analytics_id,
            cbc_users_raw.user_id,
            cbc_users_raw.first_cbc_cycle_start,
            cbc_users_raw.last_cbc_cycle_start,
            cbc_users_raw.first_algo_run
    )

SELECT
    sp_users.master_id,
    sp_users.analytics_id,
    sp_users.user_id,
    cbc_users.first_cbc_cycle_start,
    cbc_users.last_cbc_cycle_start,
    cbc_users.first_algo_run,
    MIN(sp_sessions.start) AS pregnancy_mode_start
FROM cbc_users_enriched AS cbc_users
JOIN der.sp_users
        ON sp_users.user_id = cbc_users.user_id
JOIN der.sp_sessions
        ON sp_sessions.start > '2021-10-18' AND sp_sessions.master_id = sp_users.master_id AND
           sp_sessions.start >= DATEADD(DAY, 5, cbc_users.first_algo_run) AND
           sp_sessions.start < NVL(cbc_users.first_non_cbc_cycle_start, '9999-01-01')
WHERE
    life_stage = 'pregnant'
    AND (sp_users.is_test_user IS NULL OR sp_users.is_test_user IS FALSE)
GROUP BY 1, 2, 3, 4, 5, 6
ORDER BY 7
;