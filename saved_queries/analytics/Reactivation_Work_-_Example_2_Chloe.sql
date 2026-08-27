-- this feels like it should also be a subscription purchased rather than renewed?

select master_id, subscription_id, subscription_type, original_subscription_type, product_id, backend_created_at, started_at, expires_at
from der.subscriptions_events
where master_id = 2015307
order by backend_created_at