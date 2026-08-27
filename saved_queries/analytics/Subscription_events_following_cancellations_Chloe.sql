with next_subscription_types as (
select subscription_id, subscription_type,
    lead(subscription_type, 1) OVER(
            PARTITION BY subscription_id ORDER BY backend_created_at ASC) as next_subscription_type,
    lead(subscription_type, 2) OVER(
            PARTITION BY subscription_id ORDER BY backend_created_at ASC) as next_next_subscription_type
from der.subscriptions_events
where platform = 'IOS'
 )
 
 select next_subscription_type, next_next_subscription_type, count(subscription_id) 
 from next_subscription_types
 where subscription_type = 'Subscription Canceled'
 group by 1, 2 order by 3 desc;