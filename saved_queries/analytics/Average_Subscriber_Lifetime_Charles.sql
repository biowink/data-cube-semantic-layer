SELECT
    user_conversion_cohort,
    initial_subscription_duration,
    SUM(CASE WHEN is_subscribed THEN 1.0 ELSE 0 END)/COUNT(DISTINCT analytics_id) AS avg_lifetime,
    MAX(DATE_DIFF('month', user_conversion_cohort, month)) AS months_since_conversion
FROM der.subscriber_monthly_retention
WHERE
    initial_subscription_duration IN (1, 12)
    AND month < DATE_TRUNC('month', CURRENT_DATE)
    AND user_conversion_cohort >= DATE '2020-01-01'
    AND initial_subscription_source = 'mobile'
GROUP BY 1, 2
ORDER BY 1, 2
;