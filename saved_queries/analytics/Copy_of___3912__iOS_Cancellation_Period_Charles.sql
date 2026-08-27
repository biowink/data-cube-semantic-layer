WITH subscriptions AS (
SELECT
    subscription_id,
    subscription_history.platform,
    first_purchased_at,
    CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, first_purchased_at) < 30 THEN 'New User' ELSE 'Existing User' END AS user_age,
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
GROUP BY 1, 2, 3, 4, 5, 6
)
SELECT
    DATE_TRUNC('quarter', first_purchased_at) AS month,
    platform  AS segment ,
    COUNT(*) AS count_subs,
    APPROX_PERCENTILE(DATE_DIFF('day', first_purchased_at, first_canceled_ts), 0.5) AS median_days_to_cancellation
FROM subscriptions
WHERE first_purchased_at < DATE '2025-06-01' 
    AND cumulative_subscription_duration = 12
GROUP BY 1, 2
ORDER BY 1, 2
;