SELECT platform,
       analytics_id IS NULL AS is_missing_analytics_id,
       COUNT(*) AS count_sessions,
       COUNT(DISTINCT sp_device_id) AS count_devices,
       AVG(CASE WHEN first_event_id = last_event_id THEN 1.0 ELSE 0 END) AS share_only_one_event
FROM der.sessions
WHERE session_start >= CURRENT_DATE - INTERVAL '3' DAY AND platform IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;