SELECT DATE_TRUNC('week', created_at) AS week,
        reminder_type,
        COUNT(*) AS count_reminder_events
FROM der.backend_reminder_events
GROUP BY 1, 2
ORDER BY 2, 1

;