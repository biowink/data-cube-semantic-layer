SELECT
    platform,
    DATE_TRUNC('month', first_purchased_at) AS month,
    AVG(CASE WHEN cumulative_subscription_duration > 12 THEN 1.0 ELSE 0 END)
FROM core.clue_users
INNER JOIN der.subscription_history USING (analytics_id)
WHERE
    subscription_source = 'mobile'
    AND subscription_duration = 12
    AND user_converted_with_this_subscription
    AND NOT started_in_intro_offer_period
    AND DATE_DIFF('day', clue_users.backend_created_at, first_purchased_at) <= 30
    AND first_purchased_at BETWEEN DATE '2024-01-01' AND DATE '2025-05-01'
GROUP BY 1, 2
ORDER BY 1, 2
;