SELECT
    DATE_TRUNC('week', DATE_ADD('year', 1, first_purchased_at)) AS week,
    AVG(CASE WHEN cumulative_subscription_duration = 24 THEN 1.0 ELSE 0 END) AS share_renewed
FROM der.subscription_history
WHERE subscription_source = 'web'
    AND DATE_TRUNC('week', DATE_ADD('year', 1, first_purchased_at)) < CURRENT_DATE - INTERVAL '7' DAY 
GROUP BY 1
ORDER BY 1
;