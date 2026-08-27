with old as (
    select
        date,
        sum(cost) as cost,
        sum(installs) as installs,
        sum(d0_created_account_conversions) as d0_backend_created_account_conversions,
        min(date) as min_date,
        max(date) as max_date
    from intermediate.adjust_campaign_performance
    group by 1
),

new as (
    select
        date,
        sum(cost) as cost,
        sum(installs) as installs,
        sum(d0_created_account_conversions) as d0_backend_created_account_conversions,
        min(date) as min_date,
        max(date) as max_date
    from temp.intermediate_adjust_campaign_performance
    group by 1
)

select
    date,
    old.cost, new.cost,
    old.installs, new.installs,
    old.d0_backend_created_account_conversions, new.d0_backend_created_account_conversions,
    old.min_date, new.min_date,
    old.max_date, new.max_date,
    new.installs - old.installs as install_diff
from old
left join new using (date)
order by date 
