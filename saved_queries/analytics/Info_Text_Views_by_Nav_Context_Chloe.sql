select
     JSON_EXTRACT_PATH_TEXT(event_properties, 'Navigation Context'),
     count(root_id)
FROM der.events
WHERE major_app_version < 100
    AND mobile_event_name IN ('View Info Text')
    AND collector_tstamp between '2022-10-01' and  '2022-10-01'::TIMESTAMP + INTERVAL '5 weeks'
GROUP BY 1 ORDER BY 2 DESC