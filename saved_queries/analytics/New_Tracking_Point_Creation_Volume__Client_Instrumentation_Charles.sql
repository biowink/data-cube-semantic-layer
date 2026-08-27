SELECT derived_tstamp::DATE AS date,
    platform, 
    SUM(CASE WHEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') != ''
                     THEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points')::INT 
                     END) AS sum_new_tracking_points_added
FROM der.events
WHERE mobile_event_name = 'Exit Data Entry' AND derived_tstamp >= '2022-11-01'
GROUP BY 1, 2
ORDER BY 1, 2
;