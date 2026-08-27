select
    date_trunc('day', backend_updated_at) as dt,
    count(1)
from der.backend_cycles
-- where event_name = 'computed_cycles_updated'
where backend_updated_at >= date '2025-06-01'
group by 1 order by 1