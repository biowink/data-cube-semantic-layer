with cts as 
(select
    analytics_id, cycle_batch_id, cycle_start, etl_execution_date, etl_updated_at, count(1) as ct

from der.backend_predicted_cc_cycles
group by analytics_id, cycle_batch_id, cycle_start, etl_execution_date, etL_updated_at
having ct > 1
)

select etl_execution_date, count(1)
from cts
group by 1 order by 1