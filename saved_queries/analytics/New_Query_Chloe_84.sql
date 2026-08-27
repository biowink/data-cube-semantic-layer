WITH clean_to_raw_ratio_by_month AS (
    SELECT
        DATE_TRUNC('day', subev.backend_created_at) as date,
        type,
        COUNT(clean.transaction_id)::float/COUNT(subev.transaction_id) as clean_to_raw_ratio
    FROM import.subscriptions_events subev
    LEFT JOIN import.subscriptions subs ON subs.id = subev.subscription_id
    LEFT JOIN der.subscriptions_events clean ON (subev.transaction_id = clean.transaction_id)
    WHERE type IN (
    	'SUBSCRIPTION_CANCELED',
    	'SUBSCRIPTION_EXPIRED',
    	'SUBSCRIPTION_GRACE_PERIOD',
    	'SUBSCRIPTION_PURCHASED',
    	'SUBSCRIPTION_RECOVERED',
    	'SUBSCRIPTION_RENEWED',
    	'SUBSCRIPTION_REVOKED',
    	'SUBSCRIPTION_VALIDATED')
    AND subs.test_subscription IS FALSE
    AND date = '2022-11-16'
    GROUP BY 1, 2
    ORDER BY 1, 2
)

SELECT
   date,
   type,
   clean_to_raw_ratio
FROM clean_to_raw_ratio_by_month
ORDER BY 3 DESC;