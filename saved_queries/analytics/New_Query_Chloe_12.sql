select
    date_trunc('hour', created_at) as dt,
    count(1)
from der.backend_adjust_trackers
where created_at >= date '2025-06-26'
group by 1 order by 1