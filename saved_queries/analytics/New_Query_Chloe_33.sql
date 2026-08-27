select
    date_trunc('day', install_time), count(1)
from user_metrics.adjust_attribution
where install_time >= date '2026-01-15'
group by 1 order by 1