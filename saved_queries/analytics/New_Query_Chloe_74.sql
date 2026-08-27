SELECT backend_created_at::DATE,
       COUNT(*) AS count
FROM der.subscriptions_events
WHERE master_id IS NULL
  AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Free Trial')
GROUP BY 1
ORDER BY 1 DESC
;