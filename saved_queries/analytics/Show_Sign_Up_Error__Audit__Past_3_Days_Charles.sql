SELECT platform, 
        json_extract_path_text(event_properties, 'Sign Up Error') AS sign_up_error,
       json_extract_path_text(event_properties, 'Authentication Method') AS authentication_method,
       COUNT(*)
FROM der.events
WHERE derived_tstamp >= CURRENT_DATE - 3
AND major_app_version > 100
AND mobile_event_name = 'Show Sign Up Error'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;