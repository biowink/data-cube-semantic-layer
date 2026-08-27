SELECT DATE(collector_tstamp) AS collector_tstamp_dt,
       SUM(1) AS count_events,
       SUM(CASE WHEN platform IS NULL THEN 1 ELSE 0 END) AS count_events_missing_platform
FROM der.events
WHERE DATE(collector_tstamp) >= DATE('2024-06-01')
  AND schema_name = 'backend_events'
  AND mobile_event_name IN ('Takeout Completed')
GROUP BY 1
ORDER BY 1 
;