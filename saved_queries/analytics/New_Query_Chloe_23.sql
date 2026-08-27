select date_trunc('day', install_time), count(1)
from der.backend_adjust_trackers
where install_time >= date '2026-03-01'
group by 1 order by 1