WITH subscriptions_up_for_renewal AS (
    SELECT
        date_trunc('day', expires_at) as dt,
        -- date_part('w', expires_at::TIMESTAMP) as week,
        COUNT(1) as subscriptions_up_for_renewal
    FROM der.subscriptions_events
    WHERE 
    "subscription_duration" = 12 
    AND "subscription_type" IN ('Subscription Purchased', 'Subscription Renewed')
    AND expires_at >= '2021-01-01'
    group by 1
),

renewed_subscriptions AS (
    SELECT
        date_trunc('day', backend_created_at) as dt,
        -- date_part('w', backend_created_at::TIMESTAMP) as week,
        COUNT(1) as renewed_subscriptions
    FROM der.subscriptions_events
    WHERE 
    "subscription_duration" = 12 
    AND "subscription_type" IN ('Subscription Renewed')
    AND backend_created_at >= '2021-01-01'
    group by 1
),

joined AS (
SELECT
    dt,
    subscriptions_up_for_renewal,
    renewed_subscriptions
FROM subscriptions_up_for_renewal
JOIN renewed_subscriptions 
    USING(dt)
),

yoy AS (
    SELECT
     DATE_TRUNC('week', ty.dt) as week,
     SUM(ty.subscriptions_up_for_renewal) as subs_up_for_renewal_ty,
     SUM(ty.renewed_subscriptions) as renewed_subs_ty,
     SUM(ly.subscriptions_up_for_renewal) as subs_up_for_renewal_ly,
     SUM(ly.renewed_subscriptions) as renewed_subs_ly
    FROM joined ty
    JOIN joined ly ON (ty.dt = ly.dt + '365 days'::interval)
    GROUP BY week ORDER by week
)

SELECT
week,
subs_up_for_renewal_ty,
renewed_subs_ty::float/subs_up_for_renewal_ty as renewal_rate_ty,
subs_up_for_renewal_ly,
renewed_subs_ly::float/subs_up_for_renewal_ly as renewal_rate_ly

FROM yoy
WHERE week >= CURRENT_DATE - '60 days'::INTERVAL
ORDER BY week
