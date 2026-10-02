
SELECT DATE_TRUNC('hour', backend_created_at) AS hour,
       SUM(CASE WHEN is_in_intro_offer_period THEN 1 ELSE 0 END) AS promos
FROM der.subscriptions_events
WHERE backend_created_at BETWEEN '2023-06-01' AND '2023-08-01'
  AND subscription_type = 'Subscription Purchased'
  AND platform = 'IOS'
GROUP BY 1
ORDER BY 1
;
