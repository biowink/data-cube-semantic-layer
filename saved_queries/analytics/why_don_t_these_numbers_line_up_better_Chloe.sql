with purchased_subscriptions AS (
    select subscription_id
    from der.subscriptions_events
    WHERE subscription_type IN ('Subscription Purchased', 'Subscription Renewed')
    group by 1
),

sub as (
select DISTINCT
    subscription_id,
    FIRST_VALUE(CASE
                  WHEN subscription_type IN ('Subscription Purchased', 'Subscription Renewed')
                  THEN gross_sales_euro
                  END) 
        OVER (PARTITION BY subscription_id ORDER BY backend_created_at
              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
      AS initial_price_paid_euro
from der.subscriptions_events
join purchased_subscriptions USING (subscription_id)
)

select count(subscription_id), count(initial_price_paid_euro)
from sub