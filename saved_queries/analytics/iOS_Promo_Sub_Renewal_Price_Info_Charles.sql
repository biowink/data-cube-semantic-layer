SELECT all_subscriptions_events.subscription_id,
       all_subscriptions_events.analytics_id,
       product_id,
       backend_created_at,
       started_at,
       customer_price,
       gross_sales_euro,
       gross_sales_full_price_euro
FROM der.all_subscriptions_events
WHERE subscription_type = 'Subscription Renewed'
  AND backend_created_at >= '2024-01-01'
  AND platform = 'ios'
  AND subscription_duration = 12
  AND product_id LIKE '%promo%'
LIMIT 500
;