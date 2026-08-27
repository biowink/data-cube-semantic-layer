with snowplow as (
    select
        analytics_id,
        account_created_ts
    from der.web_sessions
    where ELEMENT_AT(SPLIT(ELEMENT_AT(SPLIT(first_page_url, 'gad_campaignid='), 2), '&'), 1) = '22921307250'
    and account_created_ts is not null
    and session_start >= date '2024-09-01'
)

select
    user_account_source.account_source,
    -- adjust_attribution.network,
    -- adjust_attribution.campaign,
    -- adjust_attribution.adgroup,
    -- adjust_attribution.creative,
    count(snowplow.analytics_id) as snowplow,
    count(users.analytics_id) as users

from snowplow
left join der.users on (snowplow.analytics_id = users.analytics_id)
left join user_metrics.adjust_attribution on (snowplow.analytics_id = adjust_attribution.analytics_id)
left join user_metrics.user_account_source on (snowplow.analytics_id = user_account_source.analytics_id)
group by 1


select date_trunc('day', account_created_at) as dt, account_source, count(1)
from der.users
left join user_metrics.user_account_source on (users.analytics_id = user_account_source.analytics_id)
where account_created_at >= date '2025-08-01'
group by 1, 2
order by 1, 2