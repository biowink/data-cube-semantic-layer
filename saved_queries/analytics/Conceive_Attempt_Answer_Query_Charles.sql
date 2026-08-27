SELECT
    NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'Attempt Timespan'),'')  AS attempt_timespan_answer,
    COUNT(DISTINCT sp_device_id) AS user_count
FROM
    der.events
WHERE 
    derived_tstamp >= CURRENT_DATE - 30 
    AND mobile_event_name = 'Answer Conceive Attempt Timespan' 
    AND (NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'Attempt Timespan'),'') ) IS NOT NULL
GROUP BY
    1
ORDER BY
    2 DESC