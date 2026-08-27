WITH cancellations AS (
        SELECT 
          subscription_id, 
          transaction_id as cancellation_transaction_id,
          backend_created_at as cancellation_backend_created_at,
          expires_at as cancellation_expires_at
        FROM der.subscriptions_events
        WHERE subscription_type in ('Subscription Canceled')
            AND platform = 'IOS'
    ),
reactivation_timestamp AS (
    SELECT
        cancellations.subscription_id,
        cancellation_transaction_id,
        cancellation_backend_created_at,
        min(backend_created_at) as first_backend_created_at
    FROM cancellations
    INNER JOIN der.subscriptions_events
    USING (subscription_id)
    WHERE subscriptions_events.subscription_type in ('Subscription Purchased', 'Subscription Renewed')
      and subscriptions_events.backend_created_at > cancellations.cancellation_backend_created_at + '32 days'::interval
      and subscriptions_events.backend_created_at > cancellations.cancellation_expires_at + '32 days'::interval
    GROUP BY cancellations.subscription_id, cancellation_transaction_id, cancellation_backend_created_at
    ),
    
reactivations AS (
SELECT 
  subscriptions_events.subscription_id,
  transaction_id,
  subscription_type,
  subscription_duration,
  product_id,
  started_at, backend_created_at, backend_updated_at, expires_at, 
  is_in_intro_offer_period,
  cancellation_transaction_id,
  cancellation_backend_created_at,
  backend_created_at - cancellation_backend_created_at as time_to_renewal,
  extract(days from backend_created_at - cancellation_backend_created_at) as days_to_renewal
FROM reactivation_timestamp
LEFT JOIN der.subscriptions_events
ON (reactivation_timestamp.subscription_id = subscriptions_events.subscription_id
    AND reactivation_timestamp.first_backend_created_at = subscriptions_events.backend_created_at)
WHERE subscriptions_events.subscription_type in ('Subscription Purchased', 'Subscription Renewed')

)


SELECT DATE_TRUNC('week', backend_created_at) AS week_created_at, subscription_duration, COUNT(DISTINCT subscription_id)
FROM reactivations
WHERE is_in_intro_offer_period IS NULL AND days_to_renewal IN (90,91,92)
GROUP BY 1, 2