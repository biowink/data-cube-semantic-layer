select date_trunc('day', backend_created_at), platform, count(transaction_id)
from der.subscriptions_events
where backend_created_at >= '2022-12-15'
group by 1, 2 
order by 1, 2