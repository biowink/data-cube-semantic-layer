SELECT DATE(derived_tstamp),
       COUNT(*)
FROM der.events
WHERE mobile_event_name = 'Enter Experiment'
    AND derived_tstamp >= DATE '2025-01-01'
    AND platform = 'ios'
GROUP BY 1
ORDER BY 1
;