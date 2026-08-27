SELECT subscription_type,
       COUNT(*) AS count_events,
       AVG(CASE WHEN customer_currency IS NULL THEN 1::FLOAT ELSE 0 END) AS share_missing_currency
FROM der.subscriptions_events
WHERE backend_created_at >= '2022-01-01'
GROUP BY 1
ORDER BY 1
;
