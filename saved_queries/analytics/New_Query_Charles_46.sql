SELECT derived_tstamp::DATE,
       COUNT(*) AS count_events,
       COUNT(DISTINCT analytics_id) AS count_users
FROM der.events
WHERE platform = 'android' AND mobile_event_name = 'Open Data Entry' AND derived_tstamp >= CURRENT_DATE - 30
GROUP BY 1
ORDER BY 1 DESC
;