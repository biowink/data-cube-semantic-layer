SELECT backend_created_at::DATE,
       COUNT(*) AS count_cancellations,
       AVG(CASE WHEN is_trial_period is true THEN 1::FLOAT ELSE 0 END) AS share_in_trial_period
FROM import.subscriptions_events
WHERE backend_created_at >= CURRENT_DATE - 30 AND type = 'SUBSCRIPTION_CANCELED'
GROUP BY 1
ORDER BY 1
;