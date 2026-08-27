with new as (
    select
        date,
        sum(cost) as cost,
        sum(installs) as installs,
        sum(d0_backend_created_account_conversions) as d0ac
    from temp.intermediate_adjust_campaign_performance
    where network = 'Apple Search Ads'
    group by 1
),

old as (
    select
        date,
        sum(cost) as cost,
        sum(installs) as installs,
        sum(d0_backend_created_account_conversions) as d0ac
    from intermediate.adjust_campaign_performance
    where network = 'Apple Search Ads'
    group by 1
)

select
    date,
    old.cost as old_cost, new.cost as new_cost, new.cost - old.cost as cost_diff,
    old.installs as old_installs, new.installs as new_installs, new.installs - old.installs as installs_diff,
    old.d0ac as old_d0ac, new.d0ac as new_d0ac, new.d0ac - old.d0ac as d0ac_diff
from old
join new using(date)