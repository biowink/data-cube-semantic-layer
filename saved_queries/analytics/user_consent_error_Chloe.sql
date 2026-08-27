-- SELECT
--     DATE_TRUNC('day', derived_tstamp) as dt,
--     COUNT(distinct session_id) as sessions, 
--     COUNT(distinct case when event_name != 'user.consent' THEN session_id else null end) 
--         as sessions_ohne_consent_event
-- FROM der.web_events
-- WHERE derived_tstamp >= date '2025-07-01'
-- group by 1 order by 1

with sessions as (
    SELECT
        session_id,
        MAX(CASE WHEN event_name = 'user.consent' THEN 1 ELSE 0 END) AS has_consent_event,
        MAX(CASE WHEN event_name != 'user.consent' THEN 1 ELSE 0 END) AS has_other_event,
        MIN(derived_tstamp) as tstamp
    FROM der.web_events
    WHERE derived_tstamp >= date '2025-07-01'
    GROUP BY 1
)

select
    date_trunc('day', tstamp) as dt,
    case when has_consent_event = 1 and has_other_event = 1 then 'has normal events and user.consent event'
         when has_consent_event = 0 and has_other_event = 1 then 'has normal events but no user.consent event'
         when has_consent_event = 1 and has_other_event = 0 then 'has user.consent but no other events'
         else 'wtf' end as cat,
    count(1) as sessions
from sessions
group by 1, 2
order by 1, 2