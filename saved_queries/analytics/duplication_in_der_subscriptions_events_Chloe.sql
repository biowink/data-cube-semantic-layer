with cts as (
    select subscription_type,
        transaction_id,
        count(1) as ct
    from der.subscriptions_events
    group by 1, 2
)

select subscription_type, count(transaction_id) as ct_of_duplicates
from cts
where ct > 1
group by 1