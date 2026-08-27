SELECT DATE_TRUNC('day', backend_created_at) AS date,
       EXTRACT(HOUR from backend_created_at) AS hour_of_day,
       COUNT(*) AS count_transactions,
       SUM(gross_sales_euro) AS count_sales
FROM der.subscriptions_events
WHERE DATE(backend_created_at) IN (DATE('2024-09-02'),DATE('2024-08-19'),DATE('2024-08-05'))
AND subscription_type = 'Subscription Purchased' AND platform = 'IOS'
GROUP BY 1, 2
ORDER BY 1, 2
;