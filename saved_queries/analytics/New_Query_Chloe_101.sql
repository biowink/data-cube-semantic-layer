SELECT month_diff,
    platform,
    start_month,
    COUNT(new_subscriptions) as users
FROM intermediate.subscriptions_retentions
WHERE country IS NOT NULL and subscription_duration = 12 AND month_diff IN (12,24)
GROUP BY 1, 2, 3