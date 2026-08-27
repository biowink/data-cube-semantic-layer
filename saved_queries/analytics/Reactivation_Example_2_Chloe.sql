WITH cancel AS (
    SELECT master_id, RIGHT(subscription_id, 6) as subsc_id, RIGHT(transaction_id, 6) as txn_id, platform, started_at, expires_at, product_id, backend_created_at
    FROM der.subscriptions_events
    WHERE subscription_type = 'Subscription Canceled'
),

reactivate AS (
    SELECT 
        master_id, 
        backend_created_at AS second_created_at,
        RIGHT(subscription_id, 6) AS second_subscription_id,
        started_at AS second_started_at,
        expires_at AS second_expires_at,
        product_id AS second_product_id,
        subscription_type AS second_subscription_type, 
        original_subscription_type AS second_original_subscription_type
    FROM der.subscriptions_events
    WHERE second_subscription_type NOT IN ('')
)

SELECT TOP 150
    cancel.master_id, 
    cancel.product_id,
    cancel.subsc_id, 
    cancel.txn_id, 
    cancel.platform, 
    cancel.started_at, 
    cancel.expires_at, 
    cancel.backend_created_at,
    reactivate.second_created_at,
    reactivate.second_started_at,
    reactivate.second_expires_at,
    reactivate.second_subscription_type,
    reactivate.second_original_subscription_type,
    cancel.master_id,
    cancel.txn_id
FROM cancel
JOIN reactivate
    ON cancel.master_id = reactivate.master_id
    AND cancel.backend_created_at < reactivate.second_created_at
ORDER BY md5(cancel.master_id), second_created_at