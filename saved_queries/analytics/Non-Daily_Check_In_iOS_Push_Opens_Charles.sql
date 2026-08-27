SELECT DATE_TRUNC('week', derived_tstamp) AS date,
COUNT(DISTINCT DATE(derived_tstamp)) AS days_in_week,
       COUNT(DISTINCT analytics_id) AS count
FROM der.events
WHERE mobile_event_name = 'Tap Push Notification'
    AND platform = 'ios'
    AND derived_tstamp >= DATE '2024-01-01'
    AND COALESCE(JSON_EXTRACT_SCALAR(event_properties, '$["Push Subtype"]'), '') != 'daily check in'
    AND derived_tstamp NOT BETWEEN DATE '2024-07-01' AND DATE '2024-09-01'
GROUP BY 1
HAVING COUNT(DISTINCT DATE(derived_tstamp)) = 7
ORDER BY 1
LIMIT 500