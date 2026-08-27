SELECT 'Fixed Version' AS version,
    platform,
    COUNT(1) AS total_records,
       SUM(CASE WHEN id IS NULL THEN 1 END) AS null_count_id,
       SUM(CASE WHEN subscription_id IS NULL THEN 1 END) AS null_count_subscription_id,
       SUM(CASE WHEN transaction_id IS NULL THEN 1 END) AS null_count_transaction_id,
       SUM(CASE WHEN subscription_type IS NULL THEN 1 END) AS null_count_subscription_type,
       SUM(CASE WHEN platform IS NULL THEN 1 END) AS null_count_platform,
       SUM(CASE WHEN product_id IS NULL THEN 1 END) AS null_count_product_id,
       SUM(CASE WHEN subscription_duration IS NULL THEN 1 END) AS null_count_subscription_duration,
       SUM(CASE WHEN customer_price IS NULL THEN 1 END) AS null_count_customer_price,
       SUM(CASE WHEN gross_sales_euro IS NULL THEN 1 END) AS null_count_gross_sales_euro,
       SUM(CASE WHEN net_sales_euro IS NULL THEN 1 END) AS null_count_net_sales_euro,
       SUM(CASE WHEN user_id IS NULL THEN 1 END) AS null_count_user_id,
       SUM(CASE WHEN analytics_id IS NULL THEN 1 END) AS null_count_analytics_id,
       SUM(CASE WHEN master_id IS NULL THEN 1 END) AS null_count_master_id,
       SUM(CASE WHEN reactivation IS NULL THEN 1 END) AS null_count_reactivation
FROM test.subscriptions_events
WHERE backend_created_at < '2023-02-27' AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
GROUP BY 1, 2
UNION ALL
SELECT 'Current Version' AS version,
    platform,
    COUNT(1) AS total_records,
       NULL AS null_count_id,
       SUM(CASE WHEN subscription_id IS NULL THEN 1 END) AS null_count_subscription_id,
       SUM(CASE WHEN transaction_id IS NULL THEN 1 END) AS null_count_transaction_id,
       SUM(CASE WHEN subscription_type IS NULL THEN 1 END) AS null_count_subscription_type,
       SUM(CASE WHEN platform IS NULL THEN 1 END) AS null_count_platform,
       SUM(CASE WHEN product_id IS NULL THEN 1 END) AS null_count_product_id,
       SUM(CASE WHEN subscription_duration IS NULL THEN 1 END) AS null_count_subscription_duration,
       SUM(CASE WHEN customer_price IS NULL THEN 1 END) AS null_count_customer_price,
       SUM(CASE WHEN gross_sales_euro IS NULL THEN 1 END) AS null_count_gross_sales_euro,
       SUM(CASE WHEN net_sales_euro IS NULL THEN 1 END) AS null_count_net_sales_euro,
       SUM(CASE WHEN user_id IS NULL THEN 1 END) AS null_count_user_id,
       SUM(CASE WHEN analytics_id IS NULL THEN 1 END) AS null_count_analytics_id,
       SUM(CASE WHEN master_id IS NULL THEN 1 END) AS null_count_master_id,
       SUM(CASE WHEN reactivation IS NULL THEN 1 END) AS null_count_reactivation
FROM der.subscriptions_events
WHERE backend_created_at < '2023-02-27' AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
GROUP BY 1, 2
ORDER BY 1
;
