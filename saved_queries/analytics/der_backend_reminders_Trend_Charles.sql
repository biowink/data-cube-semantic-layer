SELECT DATE_TRUNC('week', created_at) AS week,
        reminder_type,
        COUNT(*) AS count_reminders_created
FROM der.backend_reminders
GROUP BY 1, 2
ORDER BY 2, 1
;