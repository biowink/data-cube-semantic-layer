select 
    platform, subscription_duration,
    tax_rate, tax_euro, store_fee_rate, store_fee_euro, gross_sales_euro, net_sales_euro,
    gross_sales_euro * (1 - tax_rate - store_fee_rate) as removing_tax_and_store_fee_via_rates,
    gross_sales_euro - tax_euro - store_fee_euro as removing_tax_and_store_fee_via_euros
    
    
    -- gross_sales_euro * (1 - tax_rate) - store_fee_euro as tax_rate_store_euro,
    -- gross_sales_euro * (1 - store_fee_rate) - tax_euro as store_fee_rate_tax_euro

from der.all_subscriptions_events
where subscription_type in ('Subscription Purchased','Subscription Renewed')
and backend_created_at >= '2024-01-01'
and is_in_intro_offer_period is false
and subscription_source = 'mobile'
limit 50