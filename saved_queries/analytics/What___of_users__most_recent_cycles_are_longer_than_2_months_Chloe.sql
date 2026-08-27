with most_recent_cycles as (
select
    analytics_id, max(cycle_start) as last_completed_cycle
from der.backend_cycles
where not cycle_predicted
and cycle_start >= date '2025-03-01'
group by 1
),

cycle_sample as (
select * from der.backend_cycles
where cycle_start >= date '2025-03-01'
and not cycle_predicted
)

select
    count(case when cycle_length >= 60 then cycle_id else null end) as long_cycles,
    count(cycle_id) as total_cycles,
    count(case when cycle_length >= 60 then cycle_id else null end)/cast(count(cycle_id) as double)
        as percent_long_cycles
from cycle_sample
join most_recent_cycles using(analytics_id)