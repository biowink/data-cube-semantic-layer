
WITH daily_totals AS (
SELECT
    DATE_DIFF('day', first_purchased_at, last_canceled_at) AS time_to_cancellation,
    platform, 
    COUNT(*) AS cancellations
FROM der.subscription_history
WHERE
    first_purchased_at BETWEEN DATE '2025-01-01' AND DATE '2025-04-01'
    AND subscription_source = 'mobile'
    AND is_expired 
    AND is_canceled
    AND subscription_duration = 12
    AND DATE_DIFF('day', first_purchased_at, last_canceled_at) < 365
    AND platform IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
)
SELECT
    time_to_cancellation,
    platform,
    cancellations * 1.0/total_cancellations AS cancellation_rate
FROM daily_totals
INNER JOIN (SELECT platform, SUM(cancellations) AS total_cancellations FROM daily_totals GROUP BY 1) USING (platform)
ORDER BY 1, 2
;