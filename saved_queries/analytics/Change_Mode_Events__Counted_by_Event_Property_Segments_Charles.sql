SELECT json_extract_path_text(event_properties, 'Previous Mode') AS previous_mode,
       json_extract_path_text(event_properties, 'New Mode') AS new_mode,
       json_extract_path_text(event_properties, 'Change Trigger') AS change_trigger,
       COUNT(*)
FROM der.sorted_events
WHERE derived_tstamp >= CURRENT_DATE - 14
AND mobile_event_name = 'Change Mode'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;