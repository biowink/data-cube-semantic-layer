SELECT
    JSON_EXTRACT_PATH_TEXT(event_properties, 'Navigation Context') as navigation_context,
    mobile_event_name,
    COUNT(root_id) as events
FROM der.sorted_events
WHERE derived_tstamp >= current_date - '30 days'::interval
  AND LEN(event_properties) < 511
GROUP BY 1, 2
ORDER BY 1, 2