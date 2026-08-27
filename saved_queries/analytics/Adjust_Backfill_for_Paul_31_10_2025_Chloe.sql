with df as (
select 
    backend_devices_v2.user_id, 
    users.backend_created_at, 
    backend_devices_v2.adjust_id,
    row_number() over (partition by backend_devices_v2.user_id, backend_devices_v2.adjust_id order by backend_created_at) as row_number

from import.users
left join import.backend_devices_v2
on (backend_devices_v2.user_id = users.user_id)
left join user_metrics.user_last_optional_consent_status
on (users.analytics_id = user_last_optional_consent_status.analytics_id)

where users.backend_created_at between date '2025-10-25' and date '2025-10-30'

and consent_usage_marketing
)

select user_id, backend_created_at, adjust_id from df where row_number = 1