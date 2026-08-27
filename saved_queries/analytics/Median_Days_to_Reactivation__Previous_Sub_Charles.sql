SELECT
    DATE_TRUNC('month', first_purchased_at) AS month,
    previous_in_intro_offer_period AS subscription_journey,
    APPROX_PERCENTILE(DATE_DIFF('day', previous_expires_at, first_purchased_at), 0.5) AS quick_turnaround
FROM (
SELECT analytics_id,
       first_purchased_at,
       started_in_intro_offer_period,
       started_at,
       LEAD(expires_at) OVER (PARTITION BY analytics_id ORDER BY first_purchased_at DESC) AS previous_expires_at,
       LEAD(started_in_intro_offer_period) OVER (PARTITION BY analytics_id ORDER BY first_purchased_at DESC) AS previous_in_intro_offer_period
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