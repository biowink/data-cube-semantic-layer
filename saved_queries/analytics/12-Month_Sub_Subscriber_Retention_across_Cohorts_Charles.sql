WITH core_transactions AS (
    SELECT
        master_id,
        subscription_id,
        platform,
        backend_created_at,
        started_at,
        expires_at,
        LOWER(platform) AS platform,
        subscription_type,
        subscription_duration,
        product_id,
        DENSE_RANK() OVER (PARTITION BY master_id ORDER BY backend_created_at) AS subscriber_index
    FROM der.subscriptions_events
    WHERE
            subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
),
    refunded_users AS (
        SELECT DISTINCT subscription_id
        FROM core_transactions
        WHERE subscription_type = 'Subscription Refunded'
    ),
    yearly_subscriptions AS (
        SELECT master_id,
               backend_created_at::DATE AS converted_at
        FROM core_transactions
        LEFT JOIN refunded_users USING (subscription_id)
        WHERE
              subscriber_index = 1
          AND subscription_type = 'Subscription Purchased'
          AND subscription_duration = 12
          AND refunded_users.subscription_id IS NULL
          AND converted_at >= '2020-01-01'
    ),
    subscription_histories AS (
        SELECT
            master_id,
            subscription_id,
            converted_at,
            subscription_duration,
            DATE_TRUNC('month', backend_created_at::DATE) AS subscription_start_month
        FROM yearly_subscriptions
                 INNER JOIN core_transactions USING (master_id)
    ),
    month_offsets AS (
        SELECT DISTINCT DATE_TRUNC('month', converted_at) AS month
        FROM yearly_subscriptions
    ),
    retained_cross AS (
        SELECT
            master_id,
            DATE_TRUNC('month', converted_at)                                         AS subscriber_cohort,
            month,
            MAX(CASE WHEN date_diff('month', subscription_start_month, month) < subscription_duration THEN 1 ELSE 0 END) AS is_retained
        FROM subscription_histories
                 CROSS JOIN month_offsets
        WHERE
            month >= subscriber_cohort
        GROUP BY 1, 2, 3
    )
SELECT subscriber_cohort,
       DATE_DIFF('month', subscriber_cohort, month) AS subscription_month,
       SUM(1) AS cohort_size,
       AVG(is_retained::FLOAT) AS retention_rate
FROM retained_cross
WHERE subscription_month IN (13, 25) AND month < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY 1, 2
ORDER BY 1, 2
;