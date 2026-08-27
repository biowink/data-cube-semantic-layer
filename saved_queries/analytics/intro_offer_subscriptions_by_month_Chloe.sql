SELECT 
    DATE_TRUNC('month', backend_created_at) as month,
    COUNT(CASE WHEN is_in_intro_offer_period is true THEN subscription_id ELSE NULL END) as intro_offer_subscriptions,
    COUNT(subscription_id) as subscriptions
FROM der.subscriptions_events
GROUP BY 1
ORDER BY 1;