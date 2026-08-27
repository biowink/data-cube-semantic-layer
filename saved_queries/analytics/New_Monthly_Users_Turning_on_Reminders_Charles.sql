SELECT COUNT(*) AS count_users
FROM (
SELECT
    analytics_id,
    MIN(created_at) AS first_created_at
FROM der.backend_reminders
WHERE created_at >= DATE '2025-01-01'
GROUP BY 1
)
WHERE first_created_at >= CURRENT_DATE - INTERVAL '30' DAY
;