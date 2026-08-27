SELECT platform, 
        json_extract_path_text(event_properties, 'Sign In Error') AS sign_in_error,
       json_extract_path_text(event_properties, 'Authentication Method') AS authentication_method,
       COUNT(*)
FROM der.events
WHERE derived_tstamp >= CURRENT_DATE - 3
AND major_app_version > 100
AND mobile_event_name = 'Show Sign In Error'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;