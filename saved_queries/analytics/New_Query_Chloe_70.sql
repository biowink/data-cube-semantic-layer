select
    mobile_event_name,
    product_tier,
    COUNT(1)
from der.events
where derived_tstamp >= '2023-06-01' 
and mobile_event_name IN ('Detect Active Subscription on Buy Screen', 'View Subscription Plans')
group by 1,2 order by 1, 2