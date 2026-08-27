-- with events as (
    select
        date_trunc('day', derived_tstamp) as dt,
        event_name,
        button_label,
        target_url,
        count(1) as events,
        count(distinct session_id) as sessions
    from der.web_events
    where page_url like '%/klarna/login?referrer%'
        and derived_tstamp >= date '2026-01-01'
    group by 1, 2, 3, 4
    order by 1, 2, 3, 4