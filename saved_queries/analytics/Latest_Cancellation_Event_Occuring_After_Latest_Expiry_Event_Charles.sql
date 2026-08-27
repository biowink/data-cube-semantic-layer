WITH sub_agg AS (
    SELECT
        subscription_id,
        MAX(CASE WHEN subscription_type = 'Subscription Canceled' THEN backend_created_at END) AS last_canceled_ts,
        MAX(CASE WHEN subscription_type = 'Subscription Expired' THEN backend_created_at END) AS last_expired_ts,
        MAX(CASE WHEN subscription_type IN ('Subscription Purchased', 'Subscription Renewed') THEN backend_created_at END) AS last_purchase_ts
    FROM der.subscriptions_events
    GROUP BY 1
)
SELECT AVG(CASE WHEN last_canceled_ts > last_expired_ts THEN 1::FLOAT ELSE 0 END)
FROM sub_agg
WHERE last_expired_ts BETWEEN '2022-07-01' AND '2023-07-01' AND last_expired_ts > last_purchase_ts
;