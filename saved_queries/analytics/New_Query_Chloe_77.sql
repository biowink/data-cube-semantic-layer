with cts as (
select user_id, count(distinct cycle_batch_id) as batches
from der.backend_cycles
group by 1
having batches > 1
),

last_execution as (
select
    user_id,
    max(etl_execution_date) as last_execution_date
from der.backend_cycles
join cts using(user_id)
group by 1
)

select last_execution_date, count(1)
from last_execution
group by 1 order by 1