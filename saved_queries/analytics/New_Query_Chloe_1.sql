with purchase_events as (
    select
        analytics_id,
        product_id,
        backend_created_at,
        subscription_type,
        gross_sales_euro,
        LAG(subscription_type) OVER (PARTITION BY analytics_id ORDER BY backend_created_at) as last_subscription_type,
        LAG(expires_at) OVER (PARTITION BY analytics_id ORDER BY backend_created_at) as last_expires_at
    from der.all_subscriptions_events
    where subscription_type in ('Subscription Purchased', 'Subscription Renewed')
    and subscription_duration = 12
    and subscription_source = 'mobile'
),

filtered_purchase_events as (
    select * from purchase_events
    where DATE_DIFF('day', last_expires_at, backend_created_at) >= 56 -- 8 weeks
      and backend_created_at between date '2026-01-01' and date '2026-08-01'
)

select
    date_trunc('month', backend_created_at) as dt,
    product_id,
    count(1) AS reactivations,
    sum(gross_sales_euro) as gross_sales_euro
from filtered_purchase_events
group by 1, 2 order by 1, 2
;