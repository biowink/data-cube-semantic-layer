with event_counts as (
    select
        session_id,
        count(event_id) as total_events,
        count(case when event_name = 'user.consent' then event_id else null end) as user_consent_events
    from der.web_events
    group by 1
)

select
    date_trunc('month', session_start) as dt,
    case when total_events = user_consent_events then 'user consent session' else 'real session' end as session_type,
    case when total_events = 1 then '1 events' else 'more events' end as session_type_2,
    count(session_id) as sessions

from der.web_sessions
left join event_counts using (session_id)
where session_start >= date '2025-01-01'

group by 1, 2, 3 order by 1, 2, 3