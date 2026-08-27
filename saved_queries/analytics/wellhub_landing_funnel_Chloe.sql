with button_click_sessions as (
    select
        session_id, device_id
    from der.web_events
    where derived_page_title in ('/partners/wellhub', '/wellhub')
    and event_name = 'button_click' and button_label = 'Create account'
    group by 1, 2
),


link_click_sessions as (
    select
        session_id, device_id
    from der.web_events
    where derived_page_title in ('/partners/wellhub', '/wellhub')
    and event_name = 'link_click' and location_target = 'Sign in'
    group by 1, 2
)

select
    date_trunc('day', session_start) as dt,
    count(distinct web_sessions.device_id) as users_landed,
    count(distinct button_click_sessions.device_id) as users_clicked_create_account,
    count(distinct link_click_sessions.device_id) as users_clicked_sign_in

from der.web_sessions
left join button_click_sessions on (web_sessions.session_id = button_click_sessions.session_id)
left join link_click_sessions on (web_sessions.session_id = link_click_sessions.session_id)

where web_sessions.session_start >= date '2025-11-01'
and first_derived_page_title in ('/partners/wellhub', '/wellhub')
group by 1 order by 1