with adjust as (
    select
        date_trunc('month', date) as dt,
        network,
        sum(d0_created_account_conversions) as d0_created_account_conversions
    from der.adjust_campaign_performance 
    where date between date '2025-06-01' and date '2025-12-01'
    and network in ('Apple Search Ads', 'Google Ads ACI', 'TikTok', 'Organic')
    group by 1, 2 order by 1, 2
),

backend as (
    select
        date_trunc('month', account_created_at) as dt,
        network,
        count(analytics_id) as new_users
    from der.users
    join user_metrics.adjust_attribution using(analytics_id)
    where account_created_at between date '2025-06-01' and date '2025-12-01'
    and network in ('Apple Search Ads', 'Google Ads ACI', 'TikTok', 'Organic')
    group by 1, 2 order by 1, 2
)

select
    coalesce(adjust.dt, backend.dt) as dt,
    coalesce(adjust.network, backend.network) as network,
    d0_created_account_conversions,
    new_users,
    cast(d0_created_account_conversions as double)/new_users as ratio
from adjust
left join backend on (adjust.dt = backend.dt and adjust.network = backend.network)