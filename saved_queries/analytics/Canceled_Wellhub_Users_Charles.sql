SELECT DATE_TRUNC('day', backend_created_at) AS week,
       COUNT(DISTINCT analytics_id) AS canceled_users
FROM der.all_subscriptions_events
WHERE subscription_type = 'Subscription Canceled' AND partner = 'gympass'
GROUP BY 1
ORDER BY 1 DESC
LIMIT 100
;