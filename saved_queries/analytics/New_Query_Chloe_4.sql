select
    date_trunc('day', collector_tstamp) as dt,
    SPLIT(page_url, '?')[1],
    count(1) as ct
from der.web_events
left join der.web_sessions on (web_events.session_id = web_sessions.session_id)
where event_name = 'page_view' and page_url like '%/success%'
and web_events.collector_tstamp >= date '2026-06-15'
and web_sessions.viewed_wellhub_signup_ts IS NOT NULL
group by 1, 2 order by 1, 2 desc
