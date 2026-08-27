select
    json_extract_path_text(event_properties, 'Navigation Context'),
    count(root_id) as events
FROM der.sorted_events
where derived_tstamp >= '2022-08-20'
and mobile_event_name = 'Open Reminders'
group by 1 order by 2 desc