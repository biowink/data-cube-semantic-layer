with button_clicks as (
    select 
        collector_tstamp,
        button_label,
        event_id,
        device_id,
        page_url,
        location_target
    from der.web_events
    where event_name in ('link_click', 'button_click')
    and derived_page_title in ('/login', '/voucher/login')
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

login_events as (
    select
        collector_tstamp,
        event_id,
        device_id
    from der.web_events
    where event_name IN ('signin', 'web_signed_in')
    and collector_tstamp >= date '2025-11-01'
),

signup_events as (
    select
        collector_tstamp,
        event_id,
        device_id
    from der.web_events
    where event_name IN ('account_created', 'signup', 'web_account_created')
    and collector_tstamp >= date '2025-11-01'
)

SELECT
    DATE_TRUNC('day', b.collector_tstamp) as dt,
    -- coalesce(nullif(coalesce(nullif(coalesce(trim(button_label), location_target), 'Sign in'), 'Sign in with email'), 'Sign up'), 'Dont have an account? Sign up now') as button_or_link_label,
    -- case when page_url like '%new.helloclue%' then 'new' else 'old' end as site,
    -- CASE WHEN b.collector_tstamp <= date '2025-12-12' then 'pre' else 'post' end as period,
    count(distinct b.device_id) as button_clicks,
    count(distinct l.device_id) as logins,
    count(distinct s.device_id) as signups,
    cast(count(distinct l.device_id) as double)/count(distinct b.device_id) as login_cvr,
    cast(count(distinct s.device_id) as double)/count(distinct b.device_id) as signup_cvr
FROM button_clicks b
INNER JOIN redeem_page_views pv
    ON (b.device_id = pv.device_id AND b.collector_tstamp BETWEEN DATE_ADD('second', -600, pv.collector_tstamp) AND DATE_ADD('second', 600, pv.collector_tstamp))
LEFT JOIN login_events l
    ON (b.device_id = l.device_id AND l.collector_tstamp BETWEEN b.collector_tstamp AND b.collector_tstamp + interval '1' hour)
LEFT JOIN signup_events s
    ON (b.device_id = s.device_id AND s.collector_tstamp BETWEEN b.collector_tstamp AND b.collector_tstamp + interval '1' hour)
    
WHERE coalesce(trim(button_label), location_target) like '%Sign%'
-- GROUP BY 1, 2 ORDER BY 1, 2 desc
GROUP BY 1 ORDER BY 1