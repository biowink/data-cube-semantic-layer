WITH fixed_version AS (
    SELECT
        'Fixed Version' AS version,
        DATE_TRUNC('month', backend_created_at::DATE) AS month,
        SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN gross_sales_euro END) AS purchase_sales,
        SUM(CASE WHEN subscription_type = 'Subscription Renewed' THEN gross_sales_euro END) AS renewal_sales,
        SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN gross_sales_euro END) AS refund_sales,
        purchase_sales + renewal_sales - refund_sales AS total_sales,
        SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN 1 END) AS purchase_transactions,
        SUM(CASE WHEN subscription_type = 'Subscription Renewed' THEN 1 END) AS renewal_transactions,
        SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN 1 END) AS refund_transactions,
        purchase_transactions + renewal_transactions - refund_transactions AS total_transactions,
        SUM(CASE WHEN subscription_type = 'Subscription Purchased' AND gross_sales_euro IS NULL THEN 1 END) AS purchase_nulls,
        SUM(CASE WHEN subscription_type = 'Subscription Renewed' AND gross_sales_euro IS NULL THEN 1 END) AS renewal_nulls,
        SUM(CASE WHEN subscription_type = 'Subscription Refunded' AND gross_sales_euro IS NULL THEN 1 END) AS refund_nulls,
        purchase_nulls + renewal_nulls - refund_nulls AS total_nulls
    FROM test.subscriptions_events
    WHERE backend_created_at::DATE < '2023-02-27' AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
    GROUP BY 1, 2
),
    current_version AS (
    SELECT
        'Fixed Version' AS version,
        DATE_TRUNC('month', backend_created_at::DATE) AS month,
        SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN gross_sales_euro END) AS purchase_sales,
        SUM(CASE WHEN subscription_type = 'Subscription Renewed' THEN gross_sales_euro END) AS renewal_sales,
        SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN gross_sales_euro END) AS refund_sales,
        purchase_sales + renewal_sales - refund_sales AS total_sales,
        SUM(CASE WHEN subscription_type = 'Subscription Purchased' THEN 1 END) AS purchase_transactions,
        SUM(CASE WHEN subscription_type = 'Subscription Renewed' THEN 1 END) AS renewal_transactions,
        SUM(CASE WHEN subscription_type = 'Subscription Refunded' THEN 1 END) AS refund_transactions,
        purchase_transactions + renewal_transactions - refund_transactions AS total_transactions,
        SUM(CASE WHEN subscription_type = 'Subscription Purchased' AND gross_sales_euro IS NULL THEN 1 END) AS purchase_nulls,
        SUM(CASE WHEN subscription_type = 'Subscription Renewed' AND gross_sales_euro IS NULL THEN 1 END) AS renewal_nulls,
        SUM(CASE WHEN subscription_type = 'Subscription Refunded' AND gross_sales_euro IS NULL THEN 1 END) AS refund_nulls,
        purchase_nulls + renewal_nulls - refund_nulls AS total_nulls
    FROM der.subscriptions_events
    WHERE backend_created_at::DATE < '2023-02-27' AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
    GROUP BY 1, 2
    )
SELECT month,
       fixed_version.purchase_sales::FLOAT/current_version.purchase_sales - 1 AS purchase_sales_change,
       fixed_version.renewal_sales::FLOAT/current_version.renewal_sales - 1 AS renewal_sales_change,
       fixed_version.refund_sales::FLOAT/current_version.refund_sales - 1 AS refund_sales_change,
       fixed_version.total_sales::FLOAT/current_version.total_sales - 1 AS total_sales_change,
       fixed_version.purchase_transactions::FLOAT/current_version.purchase_transactions - 1 AS purchase_transactions_change,
       fixed_version.renewal_transactions::FLOAT/current_version.renewal_transactions - 1 AS renewal_transactions_change,
       fixed_version.refund_transactions AS refund_transactions_fixed,
       current_version.refund_transactions AS refund_transactions_fixed,
       fixed_version.refund_transactions::FLOAT/current_version.refund_transactions - 1 AS refund_transactions_change,
       fixed_version.total_transactions::FLOAT/current_version.total_transactions - 1 AS total_transactions_change,
       fixed_version.purchase_nulls,
       fixed_version.renewal_nulls,
       fixed_version.refund_nulls,
       fixed_version.total_nulls
FROM fixed_version
LEFT JOIN current_version USING (month)
ORDER BY 1 DESC
;