SELECT DATE_TRUNC('day', tracked_at) AS week,
       clue_event_name IN ('tracking.event') AS is_tracking_event,
       COUNT(DISTINCT analytics_id) AS count_users
FROM der.backend_gympass_event_tracked
WHERE tracked_at >= '2024-01-01'
GROUP BY 1, 2
ORDER BY 1, 2
;