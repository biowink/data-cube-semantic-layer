-- why does the "recovered" event on 2021/9/18 become a renewal rather than a purchase?
 -- - the answer is because the subscription duration is not 12 months, per the flow chart in confluence. ...why though

select master_id, subscription_id, subscription_type, original_subscription_type, product_id, backend_created_at, started_at, expires_at
from der.subscriptions_events
where master_id = -9322234587
order by backend_created_at