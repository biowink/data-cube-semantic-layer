SELECT
    DATE_TRUNC('week', started_at) AS week,
    platform,
    COUNT(*) AS count_subscriptions,
    SUM(CASE WHEN is_purchased THEN 1 ELSE 0 END) AS count_conversions,
    SUM(initial_price_paid_euro) AS initial_purchase_revenue
FROM der.subscription_history
INNER JOIN core.clue_users USING (analytics_id)
WHERE
    subscription_source = 'mobile'
    AND started_at >= DATE '2026-03-16'
    AND DAY_OF_WEEK(started_at) IN (6,7)
    AND platform IS NOT NULL
    AND DATE_DIFF('day', clue_users.backend_created_at, started_at) > 0
GROUP BY 1, 2
ORDER BY 1, 2
;