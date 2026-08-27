SELECT DATE(tracked_at),
    clue_event_name,
    COUNT(DISTINCT analytics_id)
FROM der.backend_gympass_event_tracked
WHERE tracked_at >= DATE '2025-06-01'
GROUP BY 1, 2
ORDER BY 1, 2
LIMIT 500
;