with dataset as (
    select master_id, session_id, mobile_event_name, platform, derived_tstamp
    from der.events
    where derived_tstamp between '2023-03-27' and '2023-04-05'
    and major_app_version >= 102
),

lagged_dataset as (
select 
    *,
    LEAD(mobile_event_name) OVER (PARTITION BY session_id ORDER BY derived_tstamp) as next_mobile_event_name
from dataset
)

select
    platform,
    mobile_event_name,
    next_mobile_event_name,
    count(session_id) as events
FROM lagged_dataset
WHERE mobile_event_name = 'Exit Option Modal'
  AND (next_mobile_event_name in ('Exit Data Entry', 'Exit Data Entry Without Saving')
        or next_mobile_event_name is null)
group by 1,2, 3
order by 1, 4 desc