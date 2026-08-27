with old as (
select
    date as dt,
    network,
    sum(d0_created_account_conversions) as d0ac
from intermediate.adjust_campaign_performance 
where date >= date '2025-01-01'
group by 1, 2
),

new as (
select
    date as dt,
    network,
    sum(d0_created_account_conversions) as d0ac
from temp.adjust_campaign_performance 
where date >= date '2025-01-01'
group by 1, 2
)

select
    coalesce(old.dt, new.dt) as dt,
    coalesce(old.network, new.network) as network,
    old.d0ac as old_d0ac,
    new.d0ac as new_d0ac
from old
left join new 
on (old.dt = new.dt and old.network=new.network)
order by 1, 2