WITH cancellations AS (
        SELECT 
          subscription_id,
          master_id,
          transaction_id as cancellation_transaction_id,
          backend_created_at as cancellation_backend_created_at,
          expires_at as cancellation_expires_at,
          subscription_duration as cancellation_subscription_duration
        FROM der.subscriptions_events
        WHERE subscription_type = 'Subscription Canceled'
            AND platform = 'IOS'
    ),
reactivation_timestamp AS (
    SELECT
        subscriptions_events.subscription_id,
        subscriptions_events.master_id,
        cancellation_transaction_id,
        cancellation_expires_at,
        cancellation_backend_created_at,
        cancellation_subscription_duration,
        MIN(backend_created_at) as first_backend_created_at
    FROM cancellations
    INNER JOIN der.subscriptions_events
    USING (master_id)
    WHERE subscriptions_events.subscription_type in ('Subscription Purchased', 'Subscription Renewed')
      AND subscriptions_events.backend_created_at >= cancellations.cancellation_expires_at -- '1 day'::interval
      AND subscriptions_events.backend_created_at >= cancellations.cancellation_backend_created_at -- '1 day'::interval
    GROUP BY subscriptions_events.subscription_id, subscriptions_events.master_id, cancellation_transaction_id, cancellation_expires_at, 
             cancellation_backend_created_at, cancellation_subscription_duration
    ),
    
reactivations AS (
SELECT 
  subscriptions_events.subscription_id, transaction_id, subscription_type, product_id,
  started_at, backend_created_at, backend_updated_at, expires_at,
  subscription_duration,
  cancellation_transaction_id,
  cancellation_expires_at,
  cancellation_backend_created_at,
  CASE WHEN cancellation_subscription_duration = subscription_duration THEN false ELSE true END as crossgrade,
  extract(days FROM backend_created_at - cancellation_expires_at) AS days_to_renewal,
  CASE WHEN days_to_renewal >= 30 THEN true ELSE false END as renewed_after_30_days
FROM reactivation_timestamp
LEFT JOIN der.subscriptions_events
ON (reactivation_timestamp.subscription_id = subscriptions_events.subscription_id
    AND reactivation_timestamp.first_backend_created_at = subscriptions_events.backend_created_at)
WHERE subscriptions_events.subscription_type in ('Subscription Purchased', 'Subscription Renewed')
 --AND backend_created_at > cancellation_expires_at + '1 days'::interval
 --AND backend_created_at > cancellation_backend_created_at + '1 days'::interval
 )
 
SELECT 
    days_to_renewal, 
    count(subscription_id) AS reactivations
FROM reactivations
GROUP BY 1