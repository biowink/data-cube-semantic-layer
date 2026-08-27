with data as (
SELECT 
    os_name,
    adid,
    idfa,
    idfv,
    tracking_limited,
    tracking_enabled,
    event,
    event_name,
    created_at,
    network_name,
    campaign_name,
    adgroup_name,
    creative_name,
    att_status
FROM import.adjust
WHERE created_at >= current_date - '30 days'::interval
)

select 
    os_name,
    att_status,
    count(adid) as adids,
    count(idfv) as idfvs,
    count(idfa) as idfas
from data
group by 1, 2
order by 1, 2