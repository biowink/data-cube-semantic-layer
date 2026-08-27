SELECT DATE_TRUNC('month', backend_created_at) AS month,
       mode,
       COUNT(*)
FROM import.backend_user_mode_events
GROUP BY 1, 2
ORDER BY 2, 1
;