SELECT DATE(collector_tstamp) AS collector_tstamp_dt,
       COUNT(*) AS event_count
FROM der.events
WHERE DATE(collector_tstamp) >= DATE('2024-06-01')
  AND schema_name != 'backend_events'
  AND platform IS NULL
GROUP BY 1
ORDER BY 1 DESC
;