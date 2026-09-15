with message_sends as (
    select analytics_id, tstamp as message_send_tstamp, step_name
    from der.braze_message_sends 
    where campaign_or_canvas_name = 'CRM0767_trackingRemindersMonthly_engage_canvas'
),

post_sessions as (
    select
        message_sends.analytics_id,
        message_sends.message_send_tstamp,
        message_sends.step_name,
        sessions.session_start as first_session_start,
        sessions.session_id,
        ROW_NUMBER() OVER (PARTITION BY message_sends.analytics_id, message_send_tstamp ORDER BY sessions.session_start ASC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
              AS row_number
    
    from message_sends 
    left join (select * from der.sessions where session_start >= date '2025-11-01') as sessions
      on (message_sends.analytics_id = sessions.analytics_id 
            and sessions.session_start >= message_sends.message_send_tstamp)
        --   and sessions.session_start BETWEEN message_sends.message_send_tstamp AND message_sends.message_send_tstamp + interval '28' day)
),

post_sessions_final as (
    select *
    from post_sessions where row_number = 1
),

join_to_reactivations as (
    select
        post_sessions_final.analytics_id,
        post_sessions_final.message_send_tstamp,
        post_sessions_final.first_session_start,
        post_sessions_final.session_id,
        post_sessions_final.step_name,
        reactivation_attribution.message_send_id as reactivation_message_send_id,
        braze_message_sends.campaign_or_canvas_name as reactivation_campaign_or_canvas_name
    from post_sessions_final
    left join der.reactivation_attribution on (post_sessions_final.session_id = reactivation_attribution.session_id)
    left join der.braze_message_sends on (reactivation_attribution.message_send_id = braze_message_sends.id)
)

-- select 
--     -- step_name,
--     count(distinct analytics_id), count(distinct session_id), count(distinct reactivation_message_send_id)
-- from join_to_reactivations
-- group by 1


select
    reactivation_campaign_or_canvas_name, count(distinct analytics_id)
from join_to_reactivations
group by 1 order by 2 desc