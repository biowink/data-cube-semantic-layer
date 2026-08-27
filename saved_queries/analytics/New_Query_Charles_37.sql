SELECT DATE(started_at) AS date,
platform,
    AVG(CASE WHEN DATE_DIFF('day', started_at, last_canceled_at) <= 1 THEN 1.0 ELSE 0 END) AS cancellation_rate
FROM der.subscription_history
WHERE NOT has_trial AND is_purchased AND started_at >= DATE('2024-12-01') AND platform IS NOT NULL
GROUP BY 1, 2
ORDER BY 1
;