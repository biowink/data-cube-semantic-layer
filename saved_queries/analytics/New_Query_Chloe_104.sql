select
    retention_curve,
    breakout,
    predicted_rate
from der.ltv_per_breakout
WHERE subscription_duration = 12
order by 1

-- select platform, gross_sales_bucket, is_in_intro_offer_period, count(new_subscriptions) FROM intermediate.subscriptions_retentions_with_price_buckets
-- where subscription_duration = 12
-- and start_month >= '2021-07-01'
-- group by 1, 2, 3
-- order by 1, 2, 3
