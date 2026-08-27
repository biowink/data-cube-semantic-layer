select
    date_trunc('month', backend_created_at) as month,
    subscription_type,
    sum(gross_sales_euro) as sales
from der.subscriptions_events
-- where subscription_type = 'Subscription Renewed'
where backend_created_at >= '2021-08-01'
 
group by 1, 2 order by 1, 2