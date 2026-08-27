SELECT first_platform,
       first_seen::DATE AS first_seen_dt,
       COUNT(DISTINCT sp_users.master_id) AS count_users,
       COUNT(root_id) AS count_errors,
       COUNT(DISTINCT events.master_id) AS count_user_seeing_error,
       count_errors::FLOAT/count_users AS avg_d0_errors_per_user,
       count_user_seeing_error::FLOAT/count_users AS share_new_users_encountering_error
FROM der.sp_users
LEFT JOIN der.events ON sp_users.master_id = events.master_id 
                            AND DATEDIFF('day', first_seen, derived_tstamp) = 0
                            AND mobile_event_name IN ('Show Sign In Error', 'Show Sign Up Error', 'Show Error Screen')
                            AND derived_tstamp >= '2022-11-01'
WHERE first_seen >= '2022-11-01'
GROUP BY 1, 2
ORDER BY 1, 2
;