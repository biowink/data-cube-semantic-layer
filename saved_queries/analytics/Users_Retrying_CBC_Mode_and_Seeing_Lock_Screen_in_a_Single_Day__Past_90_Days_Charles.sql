WITH user_agg AS (
    SELECT
        master_id,
        derived_tstamp::DATE,
        COUNT(*) AS reentry_attempts
    FROM der.sorted_events
    WHERE
          LOWER(mobile_event_name) = LOWER('Show CBC Preboarding Lockout')
      AND derived_tstamp >= CURRENT_DATE - 90
    GROUP BY
        1, 2
),
worst_day AS (
SELECT master_id,
MAX(reentry_attempts) AS reentry_attempts
FROM user_agg
GROUP BY 1)
SELECT CASE WHEN reentry_attempts = 1 THEN '1 Attempt'
            WHEN reentry_attempts <= 3 THEN '2-3 Attempts'
            WHEN reentry_attempts <= 6 THEN '4-6 Attempts'
            WHEN reentry_attempts <= 10 THEN '7-10 Attempts'
            ELSE 'More than 10 Attempts' END AS count_retry_attempts,
       COUNT(*) AS count_users
FROM worst_day
GROUP BY 1
ORDER BY 1
;