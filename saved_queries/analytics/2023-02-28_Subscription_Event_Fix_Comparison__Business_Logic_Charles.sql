SELECT 'Fixed Version' AS version,
       platform,
       SUM(1) AS count_transactions,
       SUM(CASE WHEN is_in_intro_offer_period THEN 1 END) AS sum_is_in_intro_offer_period,
       SUM(CASE WHEN reactivation THEN 1 END) AS sum_is_reactivation
FROM test.subscriptions_events
WHERE backend_created_at < '2023-02-27' AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
GROUP BY 1, 2
UNION ALL
SELECT 'Current Version' AS version,
       platform,
       SUM(1) AS count_transactions,
       SUM(CASE WHEN is_in_intro_offer_period THEN 1 END) AS sum_is_in_intro_offer_period,
       SUM(CASE WHEN reactivation THEN 1 END) AS sum_is_reactivation
FROM der.subscriptions_events
WHERE backend_created_at < '2023-02-27' AND subscription_type IN ('Subscription Purchased', 'Subscription Renewed', 'Subscription Refunded')
GROUP BY 1, 2
ORDER BY 1, 2
;