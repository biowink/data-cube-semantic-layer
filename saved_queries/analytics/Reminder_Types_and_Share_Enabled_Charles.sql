SELECT reminder_type, COUNT(*) AS count_reminders_created , AVG(CASE WHEN enabled THEN 1::FLOAT ELSE 0 END) AS share_still_enabled
FROM der.backend_reminders
GROUP BY 1
ORDER BY 1
LIMIT 500
;