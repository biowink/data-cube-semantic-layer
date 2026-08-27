SELECT DATE_TRUNC('week', derived_tstamp) AS week,
       CASE WHEN navigation_context IN ('in-app-message', 'in app message', 'app open') THEN 'app open/IAM' WHEN navigation_context IN  ('cycle view upsell banner', 'exit data entry') THEN navigation_context ELSE 'other' END AS navigation_context,
       COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'true' THEN session_id END) AS promo_buy_screens,
       COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Product Id"]') LIKE '%promo%' THEN session_id END) AS promo_clicks,
        COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Product Id"]') LIKE '%promo%' THEN session_id END) * 1.0/
            COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'true' THEN session_id END) AS promo_ctr
FROM der.events
LEFT JOIN der.subscription_history ON events.analytics_id = subscription_history.analytics_id AND subscription_history.started_at < DATE_ADD('day', -1, derived_tstamp)
WHERE derived_tstamp BETWEEN DATE '2024-01-01' AND DATE '2025-03-14'
  AND mobile_event_name IN ('View Subscription Plans', 'Subscription Started')
  AND subscription_history.analytics_id IS NULL
  AND events.platform = 'android'
--   AND navigation_context NOT IN ('app open', 'in app message', 'in-app-message')
--   AND events.country_name != 'United States'
GROUP BY 1, 2
HAVING COUNT(DISTINCT CASE WHEN JSON_EXTRACT_SCALAR(event_properties, '$["Promotion Shown"]') = 'true' THEN session_id END) > 2000
ORDER BY 1, 2
;