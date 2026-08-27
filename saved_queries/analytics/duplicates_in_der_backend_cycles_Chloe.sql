with cts as (
select etl_execution_date, user_id, cycle_id, count(1) as ct
from der.backend_cycles
group by 1, 2, 3
)

select etl_execution_date,
    count(case when ct = 1 then 1 else null end) as rows_with_no_duplication,
    count(case when ct > 1 then 1 else null end) as rows_with_duplication
from cts
group by 1 order by 1