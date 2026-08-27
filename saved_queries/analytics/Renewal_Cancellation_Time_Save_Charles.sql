WITH subscriptions AS (
SELECT
    subscription_id,
    subscription_history.platform,
    first_purchased_at,
    started_in_intro_offer_period,
    MIN(CASE WHEN subscription_type = 'Subscription Canceled' AND mobile_subscriptions_events.backend_created_at >= DATE(first_purchased_at) THEN mobile_subscriptions_events.backend_created_at END) AS first_canceled_ts
FROM der.subscription_history
INNER JOIN core.clue_users ON clue_users.analytics_id = subscription_history.analytics_id
LEFT JOIN der.mobile_subscriptions_events USING (subscription_id)
WHERE subscription_history.subscription_source = 'mobile'
    AND subscription_history.subscription_duration = 12
    AND is_purchased
    AND first_purchased_at >= DATE '2021-01-01'
GROUP BY 1, 2, 3, 4
)
SELECT
    DATE_TRUNC('month', first_purchased_at) AS month,
    platform || '-' || CASE WHEN started_in_intro_offer_period THEN 'discount' ELSE 'fullprice' END AS segmentation,
    COUNT(*) AS count_subs,
    AVG(CASE WHEN DATE_DIFF('day', first_purchased_at, first_canceled_ts) BETWEEN 30 AND 300 THEN 1.0 ELSE 0 END) AS cancelation_diff
FROM subscriptions
WHERE DATE_DIFF('day', first_purchased_at, CURRENT_DATE) > 300
GROUP BY 1, 2
ORDER BY 1, 2
;