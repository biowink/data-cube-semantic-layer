SELECT
    date,
    COUNT(DISTINCT analytics_id)
FROM (
SELECT
    DATE_TRUNC('week', updated_at) AS date,
    analytics_id,
    plan_id,
    LAG(plan_id) OVER (PARTITION BY analytics_id ORDER BY updated_at) AS lagged_plan_id
FROM der.backend_gympass_user_updated
)
WHERE plan_id = '0' AND lagged_plan_id = '1'
GROUP BY 1
ORDER BY 1 DESC
LIMIT 100
;