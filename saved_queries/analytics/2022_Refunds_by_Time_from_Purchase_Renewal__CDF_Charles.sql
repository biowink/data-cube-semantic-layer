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
SELECT days_to_refund,
(SUM(count_refunds) OVER (ORDER BY days_to_refund ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))::FLOAT/
(SELECT SUM(count_refunds) FROM refund_timing) AS share_cumulative_refunds
FROM refund_timing
ORDER BY 1
;