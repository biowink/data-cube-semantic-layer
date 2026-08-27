SELECT subscription_type, count(1) as ct FROM der.all_subscriptions_events
GROUP BY 1
;