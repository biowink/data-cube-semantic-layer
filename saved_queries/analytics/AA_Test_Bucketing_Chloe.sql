SELECT
    JSON_EXTRACT_PATH_TEXT(event_properties, 'experiment_name', FALSE) as experiment,
    DATE_TRUNC('day', derived_tstamp) as dt,
    COUNT(DISTINCT CASE WHEN JSON_EXTRACT_PATH_TEXT(event_properties, 'variant_name', FALSE) = 'control' THEN master_id ELSE NULL END) as ctl_users,
    COUNT(DISTINCT CASE WHEN JSON_EXTRACT_PATH_TEXT(event_properties, 'variant_name', FALSE) = 'experiment' THEN master_id ELSE NULL END) as exp_users,
    exp_users::FLOAT/(exp_users + ctl_users) as share_exp
FROM der.events
WHERE mobile_event_name = 'Enter Experiment'
and derived_tstamp >= '2023-04-17'
GROUP BY 1, 2
ORDER BY 1, 2