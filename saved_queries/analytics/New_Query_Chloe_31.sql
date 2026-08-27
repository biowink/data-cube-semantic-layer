with adjust as (
    select
        date as dt,
        sum(d0_created_account_conversions) as adjust_account_creations,
        sum(installs) as adjust_installs
    from der.adjust_campaign_performance
    where date >= date '2026-01-15'
    and platform = 'android'
    group by 1 order by 1
),

snowplow as (
    select
        date_trunc('day', derived_tstamp) as dt,
        count(distinct sp_device_id) as show_welcome_screen_users
    from der.events
    where platform = 'android'
    and derived_tstamp >= date '2026-01-15'
    and mobile_event_name = 'Show Welcome Screen'
    group by 1 order by 1
),

backend_account_creations as (
    select
        date_trunc('day', account_created_at) as dt,
        count(1) as backend_account_creations_with_marketing_consent
    from der.users
    join user_metrics.user_last_session_attributes using(analytics_id)
    join user_metrics.user_last_optional_consent_status using(analytics_id)
    where account_created_at >= date '2026-01-15'
    and platform = 'android'
    and consent_usage_marketing
    group by 1 order by 1
)

select
    *
from adjust
join snowplow using (dt)
join backend_account_creations using (dt)
order by 1