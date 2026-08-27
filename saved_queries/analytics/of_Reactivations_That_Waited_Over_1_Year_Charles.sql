SELECT
    DATE_TRUNC('month', first_purchased_at) AS month,
    started_in_intro_offer_period,
    AVG(CASE WHEN DATE_DIFF('day', previous_expires_at, first_purchased_at) > 365 THEN 1.0 ELSE 0 END) AS slow_turnaround
FROM (
SELECT analytics_id,
       first_purchased_at,
       started_in_intro_offer_period,
       started_at,
       LEAD(expires_at) OVER (PARTITION BY analytics_id ORDER BY first_purchased_at DESC) AS previous_expires_at
FROM der.subscription_history
WHERE
    is_purchased
)
WHERE
    previous_expires_at IS NOT NULL
    AND first_purchased_at >= DATE '2024-01-01'
    AND first_purchased_at < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY 1, 2
ORDER BY 1, 2
;