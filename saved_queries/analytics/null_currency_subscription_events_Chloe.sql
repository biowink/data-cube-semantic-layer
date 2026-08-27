select 
    subscription_type, 
    count(case when customer_currency is null then 1 else null end) as null_currency_events,
    count(1) as all_events,
    null_currency_events::float/all_events as share,
    min(case when customer_currency is null then backend_created_at else null end) as first_null_currency_at, 
    max(case when customer_currency is null then backend_Created_at else null end) as last_null_currency_at 
from der.subscriptions_events 
where platform = 'IOS'
group by 1;