SELECT DATE(derived_tstamp) AS date,
    platform,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'View Subscription Plans' THEN analytics_id END) AS count_buy_screens,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Subscription Started' AND JSON_EXTRACT_SCALAR(event_properties, '$["Buy Screen Type"]') = 'flash sale' THEN analytics_id END) * 1.0/
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Subscription Started' AND JSON_EXTRACT_SCALAR(event_properties, '$["Buy Screen Type"]') = 'standard' THEN analytics_id END) AS uplift
FROM der.events
WHERE ((platform = 'android' AND major_app_version >= 185) OR (platform = 'ios' AND major_app_version >= 199))
    AND mobile_event_name IN ('View Subscription Plans', 'Subscription Started')
    AND derived_tstamp BETWEEN TIMESTAMP '2024-12-22 16:00:00' AND TIMESTAMP '2024-12-27 11:00:00'
GROUP BY 1, 2
ORDER BY 1, 2
;