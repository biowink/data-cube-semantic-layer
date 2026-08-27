WITH subscriptions AS (
SELECT
    subscription_id,
    subscription_history.platform,
    first_purchased_at,
    market,
    cumulative_subscription_duration,
    started_in_intro_offer_period,
    MIN(CASE WHEN subscription_type = 'Subscription Grace Period' AND mobile_subscriptions_events.backend_created_at >= DATE(first_purchased_at) THEN mobile_subscriptions_events.backend_created_at END) AS first_canceled_ts
FROM der.subscription_history
INNER JOIN core.clue_users ON clue_users.analytics_id = subscription_history.analytics_id
LEFT JOIN core.countries ON subscription_history.country = countries.country_name
LEFT JOIN der.mobile_subscriptions_events USING (subscription_id)
WHERE subscription_history.subscription_source = 'mobile'
    AND subscription_history.subscription_duration = 12
    AND is_purchased
    AND first_purchased_at >= DATE '2022-01-01'
GROUP BY 1, 2, 3, 4, 5, 6
)
SELECT
    DATE_ADD('year', 1, DATE_TRUNC('month', first_purchased_at)) AS renewal_month,
    platform,
    COUNT(*) AS count_subs,
    AVG(CASE WHEN DATE_DIFF('day', first_purchased_at, first_canceled_ts) BETWEEN 300 AND 400 AND cumulative_subscription_duration = 12 THEN 1.0 ELSE 0 END) AS cancelation_diff1
FROM subscriptions
WHERE first_purchased_at < DATE '2025-03-01' 
GROUP BY 1, 2
ORDER BY 1, 2
;