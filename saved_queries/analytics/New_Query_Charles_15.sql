SELECT DATE(tracked_at) AS date,
    clue_event_name,
    COUNT(*) AS count_events
FROM der.backend_gympass_event_tracked
WHERE tracked_at >= DATE '2025-10-01'
GROUP BY 1, 2
ORDER BY 1, 2
;