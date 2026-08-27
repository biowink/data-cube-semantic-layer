SELECT DATE(backend_created_at),
    COUNT(*)
FROM der.all_subscriptions_events
WHERE subscription_type = 'Subscription Purchased'
    AND backend_created_at BETWEEN DATE '2020-01-01' AND DATE '2021-01-01'
GROUP BY 1
ORDER BY 1
;