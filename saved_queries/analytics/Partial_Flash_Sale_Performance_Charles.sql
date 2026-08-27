SELECT
    DATE_TRUNC('week', DATE_ADD('day', 1, backend_created_at)) AS week,
    SUM(gross_sales_euro) AS total_sales,
    COUNT(DISTINCT analytics_id) AS count_users
FROM der.mobile_subscriptions_events
INNER JOIN core.calendar ON DATE(mobile_subscriptions_events.backend_created_at) = calendar."date"
WHERE discount_rate = 0.75
    AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed')
    AND is_in_intro_offer_period
    AND day_of_week IN (1,2, 3, 4, 5, 6)
    AND DATE_TRUNC('week', DATE_ADD('day', 1, backend_created_at)) >= DATE '2024-01-01'
GROUP BY 1
ORDER BY 1
LIMIT 500
;