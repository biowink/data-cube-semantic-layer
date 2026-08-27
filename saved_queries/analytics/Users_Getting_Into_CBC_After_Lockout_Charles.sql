WITH user_agg AS (
    SELECT
        master_id,
        MIN(derived_tstamp) AS first_lockout_ts,
        COUNT(*) AS reentry_attempts
    FROM der.sorted_events
    WHERE
          LOWER(mobile_event_name) = LOWER('Show CBC Preboarding Lockout')
      AND derived_tstamp >= '2021-10-01'
    GROUP BY
        1
)
SELECT COUNT(DISTINCT user_agg.master_id) AS count_users_shown_lockout_screen,
COUNT(DISTINCT sp_sessions.master_id) AS count_users_later_in_cbc,
count_users_later_in_cbc::FLOAT/count_users_shown_lockout_screen AS successful_later_entry_rate
FROM user_agg
LEFT JOIN der.sp_sessions ON user_agg.master_id = sp_sessions.master_id AND sp_sessions.start > first_lockout_ts 
  AND sp_sessions.life_stage = 'cbc'
;