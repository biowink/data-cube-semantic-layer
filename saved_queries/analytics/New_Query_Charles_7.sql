SELECT
    DATE(updated_at) AS date,
    COUNT(DISTINCT analytics_id) AS churners
FROM der.backend_gympass_user_updated
WHERE plan_id = '0'
    AND updated_at >= DATE '2026-01-01'
GROUP BY 1
ORDER BY 1
LIMIT 500
;