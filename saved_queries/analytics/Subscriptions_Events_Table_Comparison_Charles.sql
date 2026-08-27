SELECT
    DATE(DATE_TRUNC('month', created_at)) AS month,
    'new' AS source_version,
    COUNT(*) AS count_records,
    COUNT(DISTINCT id) AS count_id,
    COUNT(DISTINCT user_id) AS count_user_id,
    COUNT(DISTINCT transaction_id) AS count_transaction_id,
    COUNT(DISTINCT subscription_id) AS count_subscription_id,
    COUNT(CASE WHEN is_in_intro_offer_period THEN id END) AS count_intro_offers,
    COUNT(CASE WHEN type = 'SUBSCRIPTION_PURCHASED' THEN id END) AS count_purchases
FROM airbyte.backend_subscriptions_events
WHERE created_at < CURRENT_DATE
GROUP BY 1, 2
UNION ALL
SELECT
    DATE(DATE_TRUNC('month', created_at)) AS date,
    'old' AS source_version,
    COUNT(*) AS count_records,
    COUNT(DISTINCT id) AS count_id,
    COUNT(DISTINCT user_id) AS count_user_id,
    COUNT(DISTINCT transaction_id) AS count_transaction_id,
    COUNT(DISTINCT subscription_id) AS count_subscription_id,
    COUNT(CASE WHEN is_in_intro_offer_period THEN id END) AS count_intro_offers,
    COUNT(CASE WHEN type = 'SUBSCRIPTION_PURCHASED' THEN id END) AS count_purchases
FROM import.airbyte_backend_subscriptions_events
WHERE created_at < CURRENT_DATE
GROUP BY 1, 2
ORDER BY 1 DESC, 2
LIMIT 500
;