select
    country,
    price_bucket
FROM intermediate.subscriptions_retentions_copy
where subscription_duration = 12;