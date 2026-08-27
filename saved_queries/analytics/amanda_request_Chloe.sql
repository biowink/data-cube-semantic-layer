with cycle_counts as (
    select
        analytics_id, count(1) as cycles
    from research.cycles
    where computed_cycle_type = 'completed'
    group by 1
    having count(1) >= 3
),

birth_control_from_settings as (
    select analytics_id from user_metrics.user_last_birth_control_settings
    where type in ('copper_iud', 'shot', 'vaginal_ring', 'mini_pill', 'implant', 'hormonal_iud', 'patch', 'combined_pill')
    group by 1
),

birth_control_from_tracking as (
    select analytics_id
    from der.backend_tracking
    where category like 'birth_control%' or category like 'iud%'
    group by 1
)

select
    count(distinct cycles.analytics_id) as users, 
    count(1) as total_cycles, 
    count(distinct coalesce(birth_control_from_settings.analytics_id, birth_control_from_tracking.analytics_id)) as users_with_hbc
from research.cycles
join cycle_counts on (cycles.analytics_id = cycle_counts.analytics_id)
left join birth_control_from_settings on (cycles.analytics_id = birth_control_from_settings.analytics_id)
left join birth_control_from_tracking on (cycles.analytics_id = birth_control_from_tracking.analytics_id)
