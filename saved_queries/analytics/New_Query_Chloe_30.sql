with app_start_events as (
    select
        derived_tstamp, mobile_event_name, sp_device_id
    from der.events
    where platform = 'android'
    and mobile_event_name = 'App Start'
),

first_event_per_device as (
    select sp_device_id, min(derived_tstamp) as first_app_start_at
    from app_start_events
    group by 1
),

first_app_start_counts as (
    select
        date_trunc('day', first_app_start_at) as dt, count(sp_device_id) as first_app_start_device_count
    from first_event_per_device
    where first_app_start_at >= date '2026-01-01'
    group by 1 order by 1
),

adjust_installs as (
    select
        date as dt,
        sum(installs) as adjust_installs
    from der.adjust_campaign_performance
    where date >= date '2026-01-01'
    and platform = 'android'
    group by 1 order by 1
),

snowplow_events as (
    select
        date_trunc('day', derived_tstamp) as dt,
        count(distinct sp_device_id) as show_user_journey_screen_device_count
    from der.events
    where platform = 'android'
    and derived_tstamp >= date '2026-01-01'
    and mobile_event_name = 'Show User Journey Screen'
    group by 1
)

select *
from first_app_start_counts
join adjust_installs using (dt)
join snowplow_events using (dt)
order by dt