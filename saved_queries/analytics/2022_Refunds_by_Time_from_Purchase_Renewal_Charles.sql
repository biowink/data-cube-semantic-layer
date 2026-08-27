WITH refunded_subscriptions AS (
    SELECT DISTINCT subscription_id
    FROM der.subscriptions_events
    WHERE subscription_type = 'Subscription Refunded'
),
    purchase_histories AS (
        SELECT
            subscription_id,
            subscription_duration,
            subscription_type,
            backend_created_at AS transaction_tstamp,
            LAG(backend_created_at) OVER (PARTITION BY subscription_id ORDER BY backend_created_at) AS previous_tstamp
        FROM der.subscriptions_events
                 INNER JOIN refunded_subscriptions
                 USING (subscription_id)
        WHERE
                subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
    ),
    refund_timing AS (
        SELECT
            transaction_tstamp::DATE - previous_tstamp::DATE AS days_to_refund,
            COUNT(*) AS count_refunds
        FROM purchase_histories
        WHERE
              subscription_type = 'Subscription Refunded'
          AND transaction_tstamp >= '2022-01-01'
        GROUP BY
            1
    )
SELECT CASE WHEN days_to_refund = 0 THEN 'a. Same Day'
WHEN days_to_refund = 1 THEN 'b. Next Day'
WHEN days_to_refund <= 7 THEN 'c. Same Week'
WHEN days_to_refund <= 35 THEN 'd. 1 to 4 Weeks Later'
ELSE 'e. >4 Weeks Later' END AS refund_time,
    SUM(count_refunds)::FLOAT/(SELECT SUM(count_refunds) FROM refund_timing) * 100 AS share_refunds
FROM refund_timing
GROUP BY 1
ORDER BY 1
;