SELECT DATE_TRUNC('week', derived_tstamp) AS week,
       platform,
       SUM(CASE WHEN mobile_event_name = 'Subscription Started' AND JSON_EXTRACT_SCALAR(event_properties, '$["Product Id"]') NOT LIKE '%promo%' THEN 1.0 ELSE 0 END)/
        SUM(CASE WHEN mobile_event_name = 'View Subscription Plans' AND JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'false' THEN 1.0 ELSE 0 END) AS buy_screen_cvr
FROM der.events
WHERE mobile_event_name IN ('View Subscription Plans', 'Subscription Started')
    AND derived_tstamp >= DATE '2024-01-01'
    AND navigation_context NOT LIKE '%onboarding%'
GROUP BY 1, 2
ORDER BY 1, 2
;