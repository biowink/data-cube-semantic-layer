select 
    derived_tstamp, 
    convert_timezone('Europe/Berlin', derived_tstamp) as cet_timestamp,
    mobile_events.event_name, 
    json_extract_path_text(mobile_events.event_properties, 'experiment_name', FALSE) as experiment_name,
    event_properties
FROM (select * from atomic.events where derived_tstamp >= '{{start_date}}') as events
LEFT JOIN atomic.com_helloclue_mobile_events_1 AS mobile_events
	ON events.event_id = mobile_events.root_id
	AND events.collector_tstamp = mobile_events.root_tstamp

where mobile_events.event_name = 'Enter Experiment'
and experiment_name = '{{experiment_name}}'
ORDER BY 1, 4