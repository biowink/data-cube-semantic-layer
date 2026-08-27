WITH subscriptions AS (
SELECT
    subscription_id,
    subscription_history.platform,
    first_purchased_at,
    cumulative_subscription_duration,
    started_in_intro_offer_period,
    MIN(CASE WHEN subscription_type = 'Subscription Canceled' AND mobile_subscriptions_events.backend_created_at >= DATE(first_purchased_at) THEN mobile_subscriptions_events.backend_created_at END) AS first_canceled_ts
FROM der.subscription_history
INNER JOIN core.clue_users ON clue_users.analytics_id = subscription_history.analytics_id
LEFT JOIN der.mobile_subscriptions_events USING (subscription_id)
WHERE subscription_history.subscription_source = 'mobile'
    AND subscription_history.subscription_duration = 12
    AND is_purchased
    AND first_purchased_at >= DATE '2021-01-01'
    -- AND DATE_DIFF('day', clue_users.backend_created_at, first_purchased_at) > 30
GROUP BY 1, 2, 3, 4, 5
)
SELECT
    DATE_TRUNC('quarter', first_purchased_at) AS month,
    COUNT(*) AS count_subs,
    AVG(CASE WHEN DATE_DIFF('day', first_purchased_at, first_canceled_ts) < 30 AND cumulative_subscription_duration = 12 THEN 1.0 ELSE 0 END) AS cancelation_diff1,
    AVG(CASE WHEN DATE_DIFF('day', first_purchased_at, first_canceled_ts) BETWEEN 30 AND 300 AND cumulative_subscription_duration = 12 THEN 1.0 ELSE 0 END) AS cancelation_diff2,
    AVG(CASE WHEN DATE_DIFF('day', first_purchased_at, first_canceled_ts) > 300 AND cumulative_subscription_duration = 12 THEN 1.0 ELSE 0 END) AS cancelation_diff3
FROM subscriptions
WHERE first_purchased_at < DATE '2025-06-01' 
    AND platform = 'ios'
GROUP BY 1
ORDER BY 1
;