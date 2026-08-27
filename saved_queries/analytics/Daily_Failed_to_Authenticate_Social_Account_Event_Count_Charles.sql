SELECT platform,
       derived_tstamp::DATE AS date,
       COUNT(*) AS count_events
FROM der.events
WHERE derived_tstamp >= '2022-11-01'
    AND mobile_event_name IN ('Failed to Authenticate Social Account')
GROUP BY 1, 2
ORDER BY 1, 2
;