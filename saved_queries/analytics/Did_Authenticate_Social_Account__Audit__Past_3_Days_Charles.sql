SELECT platform,
       json_extract_path_text(event_properties, 'Sign Up Or Sign In') AS sign_up_or_sign_in,
       COUNT(*) AS count_events
FROM der.events
WHERE derived_tstamp >= CURRENT_DATE - 3
    AND mobile_event_name IN ('Did Authenticate Social Account')
 AND major_app_version > 100
GROUP BY 1, 2
ORDER BY 1, 2
;