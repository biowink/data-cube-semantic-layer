with session_counts_by_device as (
    select
        device_id, count(1) as sessions
    from der.web_sessions
    group by 1
)

select 
    date_trunc('day', session_start) as dt,
    count(1) as sessions,
    count(case when session_counts_by_device.sessions = 1 then session_id else null end) as sessions_with_no_previous_session

    
from der.web_sessions
join session_counts_by_device using(device_id)

where session_start >= date '2025-12-15'
and first_page_url like '%/signup?partner_name%'
group by 1 order by 1