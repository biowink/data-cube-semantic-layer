SELECT DATE_TRUNC('week', created_at) AS week,
        reminder_type,
        COUNT(*) AS count_scheduled_reminders
FROM der.backend_scheduled_reminders
GROUP BY 1, 2
ORDER BY 2, 1
;