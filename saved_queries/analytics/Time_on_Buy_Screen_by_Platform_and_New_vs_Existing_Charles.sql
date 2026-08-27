WITH opens AS (
    SELECT
        session_id,
        platform,
        derived_tstamp::DATE = account_created_at::DATE AS is_new_user,
        MIN(CASE WHEN mobile_event_name = 'View Subscription Plans' THEN derived_tstamp END) AS start_ts,
        MIN(CASE WHEN mobile_event_name = 'Select Plan' THEN derived_tstamp END) AS select_ts,
        MIN(CASE WHEN mobile_event_name = 'Close Subscription Plans' THEN derived_tstamp END) AS close_ts
    FROM der.events
    INNER JOIN der.users USING (analytics_id)
    WHERE
          derived_tstamp >= CURRENT_DATE - 7
      AND mobile_event_name IN ('View Subscription Plans', 'Close Subscription Plans', 'Select Plan')
      AND major_app_version >= 140
    GROUP BY 1, 2, 3
    )
SELECT platform,
       is_new_user,
       COUNT(*) AS count_sessions,
       MEDIAN(DATEDIFF('millisecond', start_ts, NVL(select_ts, close_ts))) AS time_to_close_ms
FROM opens
WHERE DATEDIFF('minute', start_ts, NVL(select_ts, close_ts)) BETWEEN 0 AND 5
GROUP BY 1, 2
ORDER BY 1, 2
;