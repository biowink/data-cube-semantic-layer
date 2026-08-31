SELECT DATE_TRUNC('week', backend_created_at),
platform,
    SUM(CASE WHEN subscription_type = 'Subscription Grace Period' THEN 1.0 END)/SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN 1.0 END)
FROM der.all_subscriptions_events
WHERE backend_created_at >= DATE '2025-04-01'
    AND subscription_type IN ('Subscription Grace Period', 'Subscription Purchased')
    AND DATE_DIFF('day', started_at, backend_created_at) < 90
    AND NOT is_in_intro_offer_period
GROUP BY 1, 2
HAVING COUNT(DISTINCT DATE(backend_created_at)) = 7
ORDER BY 1
;