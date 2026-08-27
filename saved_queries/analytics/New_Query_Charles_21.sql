SELECT major_app_version,
COUNT(*) AS count_events,
AVG(CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Last Period Start Date"]') IS NULL THEN 1.0 ELSE 0 END) AS share_null
From der.events
WHERE platform = 'android'
    AND derived_tstamp >= DATE '2023-06-01'
    AND major_app_version > 100
    AND mobile_event_name = 'Select Due Date'
    GROUP BY 1
    HAVING COUNT(*) > 1000
    ORDER BY 1
    ;