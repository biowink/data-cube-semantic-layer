with consent_events as (
    select 
        session_id,
        cast(json_extract_scalar(custom_event_properties, '$.analytical') as boolean) as analytical,
        cast(json_extract_scalar(custom_event_properties, '$.marketing') as boolean) as marketing
    from der.web_events
    where event_name = 'user.consent'
    and derived_tstamp >= date '2025-09-01'
),

consent_by_session as (
    select
        session_id,
        MIN(analytical) as analytical,
        MIN(marketing) as marketing
    from consent_events
    group by 1
)

select
    date_trunc('day', session_start) as dt,
    analytical,
    count(web_sessions.session_id) as sessions

from der.web_sessions
left join consent_by_session on (web_sessions.session_id = consent_by_session.session_id)

where session_start >= date '2025-09-01'

group by 1, 2 order by 1, 2