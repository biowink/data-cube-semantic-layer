SELECT app_version,
       derived_tstamp,
       root_id,
       mobile_event_name,
       event_properties
FROM der.events
WHERE derived_tstamp >= CURRENT_DATE - 7 AND session_id = 'f1f95f45-57dd-4d03-b96e-c48ffa2d7c34'
ORDER BY derived_tstamp
;