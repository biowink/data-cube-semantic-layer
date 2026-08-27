with button_clicks as (
    select 
        collector_tstamp,
        button_label,
        event_id,
        device_id,
        page_url,
        location_target
    from der.web_events
    where event_name in ('button_click', 'link_click')
    and derived_page_title = '/login'
    and collector_tstamp >= date '2025-11-01'
    -- and page_url like '%new.helloclue%'
),

redeem_page_views as (
    select
        collector_tstamp,
        event_id,
        device_id
    from der.web_events
    where event_name = 'page_view'
    and derived_page_title = '/redeem'
    and collector_tstamp >= date '2025-11-01'
),

login_or_signup_events as (
    select
        collector_tstamp,
        event_id,
        device_id
    from der.web_events
    where event_name IN ('account_created', 'signin', 'web_signed_in', 'signup', 'web_account_created')
    and collector_tstamp >= date '2025-11-01'
)

SELECT
    DATE_TRUNC('day', b.collector_tstamp) as dt,
    -- coalesce(trim(button_label), location_target) as button_or_link_label,
    case when page_url like '%new.helloclue%' then 'new' else 'old' end as site,
    -- CASE WHEN b.collector_tstamp <= date '2025-12-12' then 'pre' else 'post' end as period,
    count(distinct b.device_id) as button_clicks,
    count(distinct v.device_id) as logins_and_signups,
    cast(count(distinct v.device_id) as double)/count(distinct b.device_id) as cvr

FROM button_clicks b
-- INNER JOIN redeem_page_views pv
--     ON (b.device_id = pv.device_id AND b.collector_tstamp BETWEEN pv.collector_tstamp AND pv.collector_tstamp + interval '1' hour)
LEFT JOIN login_or_signup_events v
    ON (b.device_id = v.device_id AND v.collector_tstamp BETWEEN b.collector_tstamp AND b.collector_tstamp + interval '1' hour)
    
WHERE coalesce(trim(button_label), location_target) like '%Sign%'
GROUP BY 1, 2 ORDER BY 1, 2
