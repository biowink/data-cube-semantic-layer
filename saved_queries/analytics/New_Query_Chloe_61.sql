select
    date_trunc('day', backend_updated_at) as dt,
    count(1)

from der.backend_predicted_cpt_cycles
group by 1 order by 1