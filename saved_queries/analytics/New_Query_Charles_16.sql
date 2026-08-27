SELECT DATE(backend_created_at),
    COUNT(*)
FROM der.all_subscriptions_events
WHERE backend_created_at >= DATE '2025-08-01'
    AND subscription_type = 'Subscription Grace Period'
GROUP BY 1
ORDER BY 1
;