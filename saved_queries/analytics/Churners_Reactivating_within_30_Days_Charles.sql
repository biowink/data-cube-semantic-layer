SELECT
    DATE_TRUNC('month', expires_at) AS month,
    started_in_intro_offer_period,
    AVG(CASE WHEN DATE_DIFF('day', expires_at, next_purchased_at) <= 30 THEN 1.0 ELSE 0 END) AS reactivating_within_30d
FROM (
SELECT analytics_id,
       expires_at,
       started_in_intro_offer_period,
       started_at,
       LAG(first_purchased_at) OVER (PARTITION BY analytics_id ORDER BY first_purchased_at DESC) AS next_purchased_at
FROM der.subscription_history
WHERE
    is_purchased
)
WHERE
    expires_at >= DATE '2024-01-01'
    AND expires_at < DATE_ADD('month', -1, DATE_TRUNC('month', CURRENT_DATE))
GROUP BY 1, 2
ORDER BY 1, 2
;