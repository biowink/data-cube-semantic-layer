
select 
    date_trunc('day', collector_tstamp) as dt,
    button_label,
    count(1) as events,
    count(distinct device_id) as devices
from der.web_events
where event_name = 'button_click'
and derived_page_title = '/login'
and collector_tstamp >= date '2025-11-01'
group by 1, 2 order by 1, 2