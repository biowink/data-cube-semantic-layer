select
     date_trunc('month',derived_tstamp) as dt,
     COUNT(master_id) as users
     
FROM der.sorted_events
JOIN der.sp_users USING(master_id)
WHERE derived_tstamp >= '2022-01-01'
AND mobile_event_name = 'Change Mode'
AND json_extract_path_text(event_properties, 'Previous Mode') != 'postpartum'
AND json_extract_path_text(event_properties, 'New Mode') = 'pregnancy'
AND account_is_verified is TRUE
GROUP BY 1
ORDER BY 1