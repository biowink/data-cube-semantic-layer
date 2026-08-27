SELECT subscription_type, sum(customer_price) as customer_price
FROM der.subscriptions_events
WHERE backend_created_at BETWEEN '2021-12-01' AND '2022-01-01'
  AND platform = 'IOS'
  AND master_id IS NULL
  AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
  group by 1
  -- cross check with der.master_id_device_map or der.sp_users using the analytics_id or user_id