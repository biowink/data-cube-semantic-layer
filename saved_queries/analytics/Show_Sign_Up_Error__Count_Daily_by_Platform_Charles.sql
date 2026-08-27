SELECT platform, 
       derived_tstamp::DATE AS date,
       COUNT(*) AS count_events
FROM der.events
WHERE derived_tstamp >= '2022-11-01'
AND mobile_event_name = 'Show Sign Up Error'
GROUP BY 1, 2
ORDER BY 1, 2
;