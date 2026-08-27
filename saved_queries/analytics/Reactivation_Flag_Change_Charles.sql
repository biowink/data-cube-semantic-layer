SELECT DATE(DATE_TRUNC('year', backend_created_at)) AS month,
       'refactored' AS table_version,
       SUM(CASE WHEN reactivation THEN 1 END) AS count_reactivations
FROM der.mobile_subscriptions_events
WHERE subscription_type IN ('Subscription Purchased', 'Subscription Renewed')
--   AND backend_created_at < DATE('2024-07-01')
GROUP BY 1, 2
UNION ALL
SELECT DATE(DATE_TRUNC('year', backend_created_at)) AS month,
       'current' AS table_version,
       SUM(CASE WHEN reactivation THEN 1 END) AS count_reactivations
FROM der.subscriptions_events
WHERE subscription_type IN ('Subscription Purchased', 'Subscription Renewed')
--   AND backend_created_at < DATE('2024-07-01')
GROUP BY 1, 2
ORDER BY 1 DESC, 2
;