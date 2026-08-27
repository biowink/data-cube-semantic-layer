with tab as (
select 
    users.analytics_id,
    account_created_at,
    DATEDIFF('day', cycle_start, account_created_at)+1 as day_of_cycle,
    count_d7_tracking_days >= 2 AND count_d7_tracking_points >= 5 as activated,
    count_m2_tracking_points > 0 as m2_tracking_retained
from der.users
join user_metrics.new_user_activation_metrics using(analytics_id)
join user_metrics.new_user_retention_metrics using(analytics_id)
JOIN der.backend_cycles 
      ON (users.analytics_id = backend_cycles.analytics_id
          AND users.account_created_at BETWEEN backend_cycles.cycle_start and backend_cycles.cycle_end)
where account_created_at between '2023-04-01' and '2023-09-01' AND NOT cycle_excluded AND NOT cycle_predicted
)

select
    day_of_cycle,
    count(analytics_id) as users,
    avg(activated::int::float) as share_activated,
    avg(m2_tracking_retained::int::float) as share_m2_tracking_retained
from tab
where day_of_cycle <= 36
group by 1 order by 1