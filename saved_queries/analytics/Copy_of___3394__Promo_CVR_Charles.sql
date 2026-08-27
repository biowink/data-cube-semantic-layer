SELECT DATE_TRUNC('week', derived_tstamp) AS week,
       events.platform,
       COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'true' THEN events.analytics_id END) AS promo_buy_screens,
       COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Product Id"]') LIKE '%promo%' THEN events.analytics_id END) AS promo_clicks,
        COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Product Id"]') LIKE '%promo%' THEN events.analytics_id END) * 1.0/
            COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'true' THEN events.analytics_id END) AS promo_ctr
FROM der.events
LEFT JOIN der.subscription_history ON events.analytics_id = subscription_history.analytics_id AND subscription_history.started_at < DATE_ADD('day', -1, derived_tstamp)
WHERE derived_tstamp >= DATE '2023-11-01'
  AND mobile_event_name IN ('View Subscription Plans', 'Subscription Started')
--   AND subscription_history.analytics_id IS NULL
--   AND events.country_name != 'United States'
GROUP BY 1, 2
HAVING COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'true' THEN session_id END) > 400000
ORDER BY 1, 2
;