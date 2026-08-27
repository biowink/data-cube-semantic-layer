SELECT DATE_TRUNC('hour', tracked_at) AS hour,
       COUNT(*) AS count_events
FROM import.airbyte_backend_gympass_event_tracked
WHERE tracked_at >= DATE '2025-10-01'
GROUP BY 1
ORDER BY 1 DESC
;