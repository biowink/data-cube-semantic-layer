SELECT 
    subscription_duration,
    subscription_type,
COUNT(subscription_id)
FROM der.subscriptions_events
WHERE is_in_intro_offer_period is true 
    AND subscription_duration != 12
GROUP BY 1, 2 ORDER BY 1, 2
;