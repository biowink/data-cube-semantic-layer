with purchases as (
    select
        analytics_id, subscription_id, subscription_type, subscription_source, backend_created_at, expires_at
    from der.all_subscriptions_events
    where code = 'LowdownxClue'
    and expires_at < current_date
),

renewals as (
    select
        analytics_id, subscription_id, backend_created_at
    from der.all_subscriptions_events
    where subscription_type = 'Subscription Renewed'
    and subscription_source = 'web'
    and backend_created_at >= date '2025-12-01'
)


select
    p.subscription_type, p.subscription_source, count(p.analytics_id), count(r.analytics_id)
from purchases p
left join renewals r on (p.subscription_id = r.subscription_id and r.backend_created_at >= p.expires_at)
group by 1, 2



select
    subscription_source, subscription_type, count(1), count(code)
from der.all_subscriptions_events
group by 1, 2 order by 1, 2