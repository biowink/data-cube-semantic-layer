

WITH cancellations AS (
        SELECT 
          subscription_id,
          master_id,
          transaction_id AS cancellation_transaction_id,
          backend_created_at AS cancellation_backend_created_at,
          expires_at AS cancellation_expires_at
        FROM der.subscriptions_events
        WHERE subscription_type = 'Subscription Canceled'
            --AND platform = 'ANDROID'
    ),
reactivation_timestamp AS (
    SELECT
        subscriptions_events.subscription_id,
        subscriptions_events.master_id,
        cancellation_transaction_id,
        cancellation_backend_created_at,
        cancellation_expires_at,
        min(backend_created_at) AS first_backend_created_at
    FROM cancellations
    INNER JOIN der.subscriptions_events
    USING (master_id)
    WHERE subscriptions_events.subscription_type in ('Subscription Purchased', 'Subscription Renewed')
      and subscriptions_events.backend_created_at >= cancellations.cancellation_expires_at - '1 day'::interval
    GROUP BY subscriptions_events.subscription_id, subscriptions_events.master_id, cancellation_transaction_id, 
        cancellation_backend_created_at, cancellation_expires_at
    ),
    
reactivations AS (
SELECT 
  subscriptions_events.subscription_id, transaction_id, subscription_type, product_id,
  started_at, backend_created_at, backend_updated_at, expires_at, 
  subscriptions_events.master_id,
  is_in_intro_offer_period,
  cancellation_transaction_id,
  cancellation_backend_created_at,
  cancellation_expires_at,
  extract(days FROM backend_created_at - cancellation_expires_at) AS days_to_renewal,
  platform
FROM reactivation_timestamp
LEFT JOIN der.subscriptions_events
ON (reactivation_timestamp.subscription_id = subscriptions_events.subscription_id
    AND reactivation_timestamp.first_backend_created_at = subscriptions_events.backend_created_at)
WHERE subscriptions_events.subscription_type in ('Subscription Purchased', 'Subscription Renewed')
and backend_created_at > cancellation_expires_at + '32 days'::interval
AND backend_created_at > cancellation_backend_created_at + '32 days'::interval
AND backend_created_at >= '2021-03-01'

),

total_platform_users AS (
    SELECT 
        platform,
        COUNT(DISTINCT master_id) AS total_users,
        --COUNT(CASE WHEN is_in_intro_offer_period is TRUE then subscription_id ELSE null end) as total_intro_offer_purchases,
        COUNT(DISTINCT CASE WHEN is_in_intro_offer_period is TRUE then master_id ELSE null end) as total_intro_offer_users
    FROM der.subscriptions_events
    WHERE backend_created_at >= '2021-03-01'
    GROUP BY 1
),

reactivation_stats AS (
    SELECT 
        platform,
        -- COUNT(subscription_id) AS reactivations,
        -- COUNT(DISTINCT master_id) as unique_users_reactivated,
        COUNT(CASE WHEN is_in_intro_offer_period is TRUE then subscription_id ELSE null end) as reactivations_with_intro_offer,
        COUNT(DISTINCT CASE WHEN is_in_intro_offer_period is TRUE then master_id ELSE null end) as unique_users_reactivated_with_intro_offer
    FROM reactivations
    GROUP BY 1
)

SELECT platform, total_users,
    --total_intro_offer_purchases,
    total_intro_offer_users,
    -- reactivations, 
    reactivations_with_intro_offer, 
    -- unique_users_reactivated, 
    unique_users_reactivated_with_intro_offer,
    -- unique_users_reactivated::float / total_users as share_of_users_reactivated,
    unique_users_reactivated_with_intro_offer::float / total_users as share_of_users_reactivated_w_intro_offer
FROM reactivation_stats
JOIN total_platform_users 
USING(platform)
ORDER BY 1
