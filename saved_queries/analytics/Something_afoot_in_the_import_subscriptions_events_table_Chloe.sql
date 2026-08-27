SELECT
    (TO_CHAR(DATE_TRUNC('hour', subscriptions_events.backend_created_at::TIMESTAMP ), 'YYYY-MM-DD HH24')) AS backend_created_hour,
    "type" as subscription_type,
    COUNT(1) AS transaction_count
    
FROM import.subscriptions_events subscriptions_events
	LEFT JOIN import.subscriptions subs ON subs.id = subscriptions_events.subscription_id
	
	WHERE subscriptions_events.backend_created_at::TIMESTAMP >= '2022-09-20'
	AND platform = 'IOS' 
-- 	AND "type" in ('SUBSCRIPTION_PURCHASED', 'SUBSCRIPTION_RECOVERED', 'SUBSCRIPTION_RENEWED')
GROUP BY
    backend_created_hour, subscription_type
ORDER BY
    1 DESC