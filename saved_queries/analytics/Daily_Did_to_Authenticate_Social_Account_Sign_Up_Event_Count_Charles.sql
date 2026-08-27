SELECT platform,
       derived_tstamp::DATE AS date,
       COUNT(*) AS count_events
FROM der.events
WHERE derived_tstamp >= '2022-11-01'
    AND mobile_event_name IN ('Did Authenticate Social Account')
    AND json_extract_path_text(event_properties, 'Sign Up Or Sign In') = 'sign up'
GROUP BY 1, 2
ORDER BY 1, 2
;