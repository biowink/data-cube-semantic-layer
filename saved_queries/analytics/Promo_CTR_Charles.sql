SELECT DATE_TRUNC('week', derived_tstamp) AS week,
       platform,
       COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'true' THEN session_id END) AS promo_buy_screens,
       COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion"]') = 'true' THEN session_id END) AS promo_clicks,
        COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion"]') = 'true' THEN session_id END) * 1.0/
            COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'true' THEN session_id END) AS promo_ctr
FROM der.events
WHERE derived_tstamp >= DATE '2024-06-01'
  AND mobile_event_name IN ('View Subscription Plans', 'Select Plan')
GROUP BY 1, 2
HAVING COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'true' THEN session_id END) > 500000
ORDER BY 1, 2
;