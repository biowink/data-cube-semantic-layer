SELECT
    cycle_start_date, count(1)
from der.cycles
where cycle_start_date >= date '2025-10-01'
group by 1 order by 1