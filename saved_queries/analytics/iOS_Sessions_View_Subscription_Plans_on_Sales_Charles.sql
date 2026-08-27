SELECT DATE_TRUNC('day', session_start) AS date,
       EXTRACT(HOUR from session_start) AS hour_of_days,
       SUM(count_view_subscription_plans) AS sum_plans,
       SUM(CASE WHEN subscription_started_transaction_id IS NOT NULL THEN 1 ELSE 0 END) AS sum_conversions
FROM der.sessions
WHERE DATE(session_start) IN (DATE('2024-09-02'),DATE('2024-08-19'),DATE('2024-08-05'))
  AND platform = 'ios'
GROUP BY 1, 2
ORDER BY 1, 2
;