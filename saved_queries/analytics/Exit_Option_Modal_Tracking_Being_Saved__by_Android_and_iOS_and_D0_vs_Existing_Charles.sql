with exit_option_modal_sessions as (
select
    master_id,
    session_id,
    platform,
    max(derived_tstamp) as last_exited_option_modal
from der.events
where derived_tstamp >= CURRENT_DATE - 7
  and mobile_event_name = 'Exit Option Modal'
group by 1, 2, 3
)

select
    exit_option_modal_sessions.platform,
    last_exited_option_modal::DATE = first_seen::DATE AS is_user_first_day,
    count(session_id) as sessions_with_exit_option_modal,
    count(case when count_exit_data_entry > 0 then 1 else null end) as sessions_with_exit_data_entry,
    sessions_with_exit_data_entry::float/sessions_with_exit_option_modal as share_saved
from der.sessions
join der.sp_users USING (master_id)
join exit_option_modal_sessions USING (session_id)
WHERE major_app_version >= 102
group by 1, 2
ORDER BY 1, 2
;