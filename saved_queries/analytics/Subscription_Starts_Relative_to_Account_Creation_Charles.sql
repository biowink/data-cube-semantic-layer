SELECT DATE_DIFF('year', account_created_at, started_at) AS years_since_account_creation,
       COUNT(*) AS count_subscriptions
FROM import.airbyte_backend_subscriptions
LEFT JOIN der.users USING (analytics_id)
GROUP BY 1
ORDER BY 1
;