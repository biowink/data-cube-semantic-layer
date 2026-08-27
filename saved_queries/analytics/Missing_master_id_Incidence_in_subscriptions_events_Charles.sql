SELECT subscription_type,
       subscription_duration,
       COUNT(*) AS count_transactions,
       COUNT(DISTINCT master_id) AS count_distinct_users,
       AVG(CASE WHEN master_id IS NULL THEN 1::FLOAT ELSE 0 END) AS share_transactions_missing_master_id
FROM der.subscriptions_events
WHERE subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Canceled')
    AND subscription_duration IN (1, 12)
GROUP BY 1, 2
ORDER BY 1, 2
;