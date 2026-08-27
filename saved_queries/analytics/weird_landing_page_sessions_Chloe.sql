with session_sample as (
    select device_id
    from der.web_sessions
    where first_page_url = 'https://helloclue.com/signup?partner_name=whoop'
    and first_page_referrer = 'https://helloclue.com/landing/wearables/clue-plus-offer/whoop'
),

count_of_sessions_by_device_id as (
    select
        session_sample.device_id,
        count(distinct web_sessions.session_id) as sessions
    from session_sample
    left join der.web_sessions on (session_sample.device_id = web_sessions.device_id)
    group by 1
)

select sessions, count(device_id) as devices
from count_of_sessions_by_device_id
group by 1 order by 1
