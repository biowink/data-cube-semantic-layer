SELECT platform, subscription_duration, is_in_intro_offer_period, count(subscription_id)
FROM der.subscriptions_events
WHERE subscription_duration IS NOT NULL
AND started_at >= '2020-01-01'
    
group by 1, 2, 3
order by 1, 2, 3
