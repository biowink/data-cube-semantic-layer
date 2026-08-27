select 
    date_trunc('month', created_at) as dt,
    count(gpw_id) as gympass_ids,
    count(analytics_id) as analytics_ids,
    cast(count(analytics_id) as double)/count(gpw_id) as cvr
from der.backend_gympass_users
group by 1 order by 1