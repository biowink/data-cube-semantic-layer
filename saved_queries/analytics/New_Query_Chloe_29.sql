with forget_password_page_views as (
    select *
    from der.web_events
    where event_name = 'page_view'
    and page_url like '%/forgot-password%'
    and derived_tstamp >= date '2026-01-01'
),

forget_password_button_clicks as (
    select *
    from der.web_events
    where event_name = 'button_click'
    and page_url like '%/forgot-password%'
    and button_label in ('Continue', 'Continuar', 'Continuer', 'Fortfahren')
    and derived_tstamp >= date '2026-01-01'
),

password_reset_page_views as (
    select *
    from der.web_events
    where event_name = 'page_view'
    and page_url like '%/password-reset%'
    and derived_tstamp >= date '2026-01-01'
)


select
    date_trunc('day', forget_password_page_views.derived_tstamp) as dt,
    count(distinct forget_password_page_views.device_id) as viewed_forget_password_devices,
    count(distinct forget_password_button_clicks.device_id) as forget_password_clicked_continue_devices,
    count(distinct password_reset_page_views.device_id) as viewed_password_reset_devices,
    
    cast(count(distinct forget_password_button_clicks.device_id) as double) / count(distinct forget_password_page_views.device_id)
        as share_clicked_continue,
    cast(count(distinct password_reset_page_views.device_id) as double) / count(distinct forget_password_page_views.device_id)
        as share_viewed_password_reset
    
    
from forget_password_page_views 
left join forget_password_button_clicks 
    on (forget_password_page_views.device_id = forget_password_button_clicks.device_id
       and forget_password_button_clicks.derived_tstamp >= forget_password_page_views.derived_tstamp)
left join password_reset_page_views 
    on (forget_password_page_views.device_id = password_reset_page_views.device_id
       and password_reset_page_views.derived_tstamp >= forget_password_page_views.derived_tstamp)
group by 1 order by 1