SELECT DATE_TRUNC('day', derived_tstamp) AS date,
       COUNT(*) AS count_notifications,
       COUNT(DISTINCT analytics_id) AS count_users
FROM der.events
WHERE mobile_event_name = 'Push Sent'
AND derived_tstamp >= DATE '2025-07-01'
AND JSON_EXTRACT_SCALAR(event_properties, '$["push_sent.push.push_subtype"]') = 'cycle phase'
GROUP BY 1
ORDER BY 1
;