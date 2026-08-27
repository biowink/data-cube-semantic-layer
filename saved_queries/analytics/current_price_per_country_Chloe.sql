select DISTINCT
    country,
    subscription_duration,
    platform,
    FIRST_VALUE(gross_sales_euro) OVER (PARTITION BY country, subscription_duration, platform ORDER BY backend_created_at DESC
    rows between unbounded preceding and unbounded following)
        as most_recent_price
from der.subscriptions_events
where is_in_intro_offer_period is false
 and subscription_type = 'Subscription Purchased'
  
ORDER BY 1, 2, 3