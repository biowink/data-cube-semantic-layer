SELECT platform,
       DATE_TRUNC('month', session_start) AS month,
       COUNT(DISTINCT CASE WHEN subscription_started_transaction_id IS NOT NULL THEN analytics_id END)
FROM der.sessions
WHERE session_start >= '2023-01-01' AND major_app_version < 100
GROUP BY 1, 2
ORDER BY 1, 2
;