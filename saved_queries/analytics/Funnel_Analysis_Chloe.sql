with funnel_1_sessions as (
select
    master_id,
    session_id,
    platform,
    min(derived_tstamp) as first_opened_data_entry
from der.events
where derived_tstamp between '2023-03-27' and '2023-04-05'
  and mobile_event_name = '{{funnel_step_1}}'
  and major_app_version >= 102
group by 1, 2, 3
),


funnel_2_sessions as (
select
    master_id,
    session_id,
    platform,
    max(derived_tstamp) as last_exited_option_modal
from der.events
where derived_tstamp between '2023-03-27' and '2023-04-05'
  and mobile_event_name = '{{funnel_step_2}}'
  and major_app_version >= 102
group by 1, 2, 3
)


select
    funnel_1_sessions.platform,
    count(funnel_1_sessions.session_id) as sessions_funnel_1,
    count(funnel_2_sessions.session_id) as sessions_funnel_2,
    sessions_funnel_2::float/sessions_funnel_1 as share

from funnel_1_sessions
LEFT join funnel_2_sessions on (funnel_1_sessions.session_id = funnel_2_sessions.session_id)
group by 1