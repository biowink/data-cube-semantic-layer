WITH trial_subs AS (
SELECT started_at,
       platform,
       subscription_id,
       SUM(CASE WHEN subscription_type = 'Subscription Free Trial' THEN 1 ELSE 0 END) AS has_trial,
       SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN 1 ELSE 0 END) AS has_purchase,
       SUM(CASE WHEN subscription_type = 'Subscription Grace Period' THEN 1 ELSE 0 END) AS has_grace_period
FROM der.mobile_subscriptions_events
WHERE started_at BETWEEN DATE('2023-01-01') AND DATE('2024-10-31')
    AND subscription_duration = 12
GROUP BY 1, 2, 3
)
SELECT DATE_TRUNC('month', started_at) AS month,
        platform,
       AVG(CASE WHEN has_grace_period > 0 THEN 1.0 ELSE 0 END)
FROM trial_subs
WHERE has_trial > 0 AND has_purchase = 0
GROUP BY 1, 2
ORDER BY 2, 1
;
