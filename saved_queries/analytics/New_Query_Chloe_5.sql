with clicks as (
    select
        analytics_id
    from der.braze_message_clicks
    where campaign_or_canvas_name like '%MembersStories%'
    and tstamp >= date '2026-06-01'
    group by 1
)

select
    date_trunc('week', session_start) as dt,
    case when clicks.analytics_id is not null then true else false end as clicked_member_stories_campaign,
    count(distinct sessions.analytics_id) as sessions,
    count(distinct case when count_exit_data_entry > 0 then sessions.analytics_id else null end) as sessions_tracked,
    cast(count(case when count_exit_data_entry > 0 then 1 else null end) as double) / count(1) as share_tracked
from der.sessions
left join clicks on (sessions.analytics_id = clicks.analytics_id)
where session_start >= date '2026-05-01'
group by 1, 2 order by 1, 2