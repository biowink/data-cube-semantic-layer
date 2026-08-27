-- -- funnel from /hsa-fsa/signup
with signup_views as (
    select *
    from der.web_events
    where derived_tstamp >= date '2026-01-01'
      and event_name = 'page_view'
      and page_url like '%/hsa-fsa/signup%'
),

checkout_views as (
    select *
    from der.web_events
    where derived_tstamp >= date '2026-01-01'
      and event_name = 'page_view'
      and page_url like '%/hsa-fsa/checkout%'
),

error_views as (
    select *
    from der.web_events
    where derived_tstamp >= date '2026-01-01'
      and event_name = 'page_view'
      and page_url like '%/hsa-fsa/error%'
),

success_views as (
    select *
    from der.web_events
    where derived_tstamp >= date '2026-01-01'
      and event_name = 'page_view'
      and page_url like '%/success%'
)

select
    -- date_trunc('week', s.derived_tstamp) as dt,
    count(distinct s.event_id) as signup_views,
    count(distinct e.event_id) as error_views,
    count(distinct c.event_id) as checkout_views,
    count(distinct suc.event_id) as success_views

from signup_views s
left join error_views e on (s.session_id = e.session_id and e.derived_tstamp > s.derived_tstamp)
left join checkout_views c on (s.session_id = c.session_id and c.derived_tstamp > s.derived_tstamp)
left join success_views suc on (s.session_id = suc.session_id and suc.derived_tstamp > c.derived_tstamp)
-- group by 1 order by 1

-- -- starting with /hsa-fsa/checkout
with checkout_views as (
    select *
    from der.web_events
    where derived_tstamp >= date '2026-01-01'
      and event_name = 'page_view'
      and page_url like '%/hsa-fsa/checkout%'
),

success_views as (
    select *
    from der.web_events
    where derived_tstamp >= date '2026-01-01'
      and event_name = 'page_view'
      and page_url like '%/success%'
)

select
    -- date_trunc('week', c.derived_tstamp) as dt,
    count(distinct c.event_id) as checkout_views,
    count(distinct s.event_id) as success_views,
    cast(count(distinct s.event_id) as double)/count(distinct c.event_id) as cvr

from checkout_views c
left join success_views s on (s.session_id = c.session_id and s.derived_tstamp > c.derived_tstamp)
-- group by 1 order by 1

-- starting with 25 banner button
-- with login_views as (
--     select *
--     from der.web_events
--     where derived_tstamp >= date '2026-01-01'
--       and event_name = 'page_view'
--       and page_url like '%/login?discount_code=BANNER25%'
-- ),

-- checkout_views as (
--     select *
--     from der.web_events
--     where derived_tstamp >= date '2026-01-01'
--       and event_name = 'page_view'
--       and page_url like '%/checkout%'
-- ),

-- subscriptions as (
--     select *
--     from der.web_events
--     where derived_tstamp >= date '2026-01-01'
--       and event_name = 'subscription'
-- ),

-- account_views as (
--     select *
--     from der.web_events
--     where derived_tstamp >= date '2026-01-01'
--       and event_name = 'page_view'
--       and page_url like '%/account%'
-- )

-- select
--     -- date_trunc('week', l.derived_tstamp) as dt,
--     count(distinct l.event_id) as login_views,
--     count(distinct c.event_id) as checkout_views,
--     count(distinct s.event_id) as subscriptions,
--     cast(count(distinct s.event_id) as double)/count(distinct c.event_id) as subscriptions_over_checkout_views,
--     count(distinct a.event_id) as account_views,
--     cast(count(distinct a.event_id) as double)/count(distinct c.event_id) as account_views_over_checkout_views

-- from login_views l
-- left join checkout_views c on (l.session_id = c.session_id and c.derived_tstamp > l.derived_tstamp)
-- left join subscriptions s on (c.session_id = s.session_id and s.derived_tstamp > c.derived_tstamp)
-- left join account_views a on (c.session_id = a.session_id and a.derived_tstamp > c.derived_tstamp)
-- group by 1 order by 1