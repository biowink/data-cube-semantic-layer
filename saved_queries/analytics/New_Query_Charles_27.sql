SELECT DATE_TRUNC('month', derived_tstamp) AS month,
       events.navigation_context,
       COUNT(*) AS count_subs
FROM der.events
WHERE mobile_event_name = 'Subscription Started'
    AND derived_tstamp >= DATE '2024-09-01'
    AND platform = 'ios'
    AND JSON_EXTRACT_SCALAR(event_properties, '$["Product Id"]') LIKE '%pro.sub.1m%'
GROUP BY 1, 2
ORDER BY 1, 2
;