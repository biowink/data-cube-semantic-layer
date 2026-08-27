select
    date_trunc('day', collector_tstamp),
    count(1)
from der.cycle_phases
group by 1 order by 1