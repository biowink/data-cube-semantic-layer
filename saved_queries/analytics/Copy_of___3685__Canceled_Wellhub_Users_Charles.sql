SELECT DATE_TRUNC('week', backend_created_at) AS week,
       country = 'Brazil',
       COUNT(DISTINCT analytics_id) AS canceled_users
FROM der.all_subscriptions_events
WHERE
    subscription_type = 'Subscription Canceled' AND partner = 'gympass'
    AND backend_created_at >= DATE '2024-01-01'
    AND country != 'United States'
GROUP BY 1, 2
ORDER BY 1 DESC, 2
;