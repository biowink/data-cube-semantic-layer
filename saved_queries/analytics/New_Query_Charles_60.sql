SELECT JSON_EXTRACT_PATH_TEXT(event_properties, 'Authentication Method') AS authentication_method,
       derived_tstamp::DATE AS date,
       COUNT(*) AS count_events
FROM der.events
WHERE derived_tstamp >= '2023-01-01'
    AND mobile_event_name IN ('Failed to Authenticate Social Account')
    AND platform = 'android'
GROUP BY 1, 2
ORDER BY 1, 2
;