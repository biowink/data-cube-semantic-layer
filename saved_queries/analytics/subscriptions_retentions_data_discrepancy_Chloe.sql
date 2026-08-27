-- from intermediate.subscriptions_retentions in redshift
SELECT
    month_diff,
    COUNT(DISTINCT new_subscriptions) as subsc,
    COUNT(DISTINCT renewal) as renewals,
    renewals::float/subsc as renewal_rate
FROM intermediate.subscriptions_retentions
WHERE subscription_duration = 12 AND month_diff in (12, 24)
GROUP BY 1
ORDER BY 1;


-- from a copy of intermediate.subscriptions_retentions created today
SELECT
    month_diff,
    COUNT(DISTINCT new_subscriptions) as subsc,
    COUNT(DISTINCT renewal) as renewals,
    renewals::float/subsc as renewal_rate
FROM intermediate.subscriptions_retentions_duplicate
WHERE subscription_duration = 12 AND month_diff in (12, 24)
GROUP BY 1
ORDER BY 1;