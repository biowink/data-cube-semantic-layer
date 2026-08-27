select
    cycle_start_date,
    computed_cycle_type, 
    count(1) as cycles
from der.cycles
where cycle_start_date between date '2025-10-01' and date '2026-02-01'
group by 1, 2 order by 1, 2