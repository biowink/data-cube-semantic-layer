SELECT
    (TO_CHAR(DATE_TRUNC('hour', subscriptions_events.backend_created_at::TIMESTAMP ), 'YYYY-MM-DD HH24')) AS backend_created_hour,
    original_subscription_type,
    COUNT(1) AS transaction_count
    
FROM der.subscriptions_events
	
	WHERE subscriptions_events.backend_created_at::TIMESTAMP >= '2022-09-20'
	AND platform = 'IOS'
GROUP BY
    backend_created_hour, original_subscription_type
ORDER BY
    1 DESC