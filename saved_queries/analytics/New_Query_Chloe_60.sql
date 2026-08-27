select
    cycle_start,
    count(1)

from der.backend_cycles
where cycle_start between date '2023-01-01' and date '2026-01-01'
group by 1 order by 1