SELECT
    DATE(DATE_TRUNC('month', created_at)) AS month,
    'new' AS source_version,
    COUNT(*) AS count_records,
    COUNT(DISTINCT id) AS count_id,
    COUNT(DISTINCT user_id) AS count_user_id,
    COUNT(DISTINCT analytics_id) AS count_analytics_id,
    COUNT(CASE WHEN is_in_intro_offer_period THEN id END) AS count_intro_offers,
    COUNT(CASE WHEN platform = 'IOS' THEN id END) AS count_ios,
    COUNT(CASE WHEN state = 'ACTIVE' THEN id END) AS count_active
FROM airbyte.backend_subscriptions
WHERE created_at < CURRENT_DATE
GROUP BY 1, 2
UNION ALL
SELECT
    DATE(DATE_TRUNC('month', created_at)) AS date,
    'old' AS source_version,
    COUNT(*) AS count_records,
    COUNT(DISTINCT id) AS count_id,
    COUNT(DISTINCT user_id) AS count_user_id,
    COUNT(DISTINCT analytics_id) AS count_analytics_id,
    COUNT(CASE WHEN is_in_intro_offer_period THEN id END) AS count_intro_offers,
    COUNT(CASE WHEN platform = 'IOS' THEN id END) AS count_ios,
    COUNT(CASE WHEN state = 'ACTIVE' THEN id END) AS count_active
FROM import.airbyte_backend_subscriptions
WHERE created_at < CURRENT_DATE
GROUP BY 1, 2
ORDER BY 1 DESC, 2
LIMIT 500
;