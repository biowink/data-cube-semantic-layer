SELECT json_extract_path_text(event_properties, 'Reminder Type') AS reminder_type,
       json_extract_path_text(event_properties, 'Toggle State') AS toggle_state,
       COUNT(DISTINCT analytics_id) AS count_users
FROM der.events
WHERE derived_tstamp >= CURRENT_DATE - 2 AND mobile_event_name = 'Toggle Reminder'
  AND json_extract_path_text(event_properties, 'Reminder Type') LIKE '%fertile window%'
GROUP BY 1, 2
ORDER BY 1, 2
;