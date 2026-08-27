WITH user_agg AS (
    SELECT
        master_id,
        COUNT(DISTINCT derived_tstamp::DATE) AS reentry_attempt_days,
        COUNT(*) AS reentry_attempts
    FROM der.sorted_events
    WHERE
          LOWER(mobile_event_name) = LOWER('Show CBC Preboarding Lockout')
      AND derived_tstamp >= CURRENT_DATE - 90
    GROUP BY
        1
)
SELECT LEAST(reentry_attempts, 10) AS reentry_attempts,
       COUNT(*)::FLOAT/(SELECT COUNT(*) FROM user_agg) AS count_users
FROM user_agg
GROUP BY 1
ORDER BY 1
;