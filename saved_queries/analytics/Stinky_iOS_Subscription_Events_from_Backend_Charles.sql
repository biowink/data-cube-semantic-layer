SELECT DATE_TRUNC('week', se.created_at) AS week,
       COUNT(*) AS count_trial_period_events,
       COUNT(CASE WHEN se.is_in_intro_offer_period THEN se.id END) AS count_also_in_intro_offer_period
FROM import.airbyte_backend_subscriptions_events se
INNER JOIN import.airbyte_backend_subscriptions s ON s.id = subscription_id
WHERE se.is_trial_period
AND platform = 'IOS'
AND se.created_at >= DATE('2024-01-01')
GROUP BY 1
ORDER BY 1
;