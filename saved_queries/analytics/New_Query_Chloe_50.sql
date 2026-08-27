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
),

sessions_with_reject_button_click as (
    select
        session_id
    from der.web_events
    where button_label in ('Reject all','Rejeter tout','Rechazar todo','Rejeitar tudo', 'Alles ablehnen')
    and derived_tstamp >= date '2025-09-01'
    group by 1
)

select
    analytical,
    sessions_with_reject_button_click.session_id is not null as has_reject_click,
    count(web_sessions.session_id) as sessions
    -- web_sessions.*

from der.web_sessions
left join consent_by_session on (web_sessions.session_id = consent_by_session.session_id)
left join sessions_with_reject_button_click on (web_sessions.session_id = sessions_with_reject_button_click.session_id)

where session_start >= date '2025-09-01' 
-- and analytical=false and sessions_with_reject_button_click.session_id is null

group by 1, 2 order by 1, 2
-- limit 20;