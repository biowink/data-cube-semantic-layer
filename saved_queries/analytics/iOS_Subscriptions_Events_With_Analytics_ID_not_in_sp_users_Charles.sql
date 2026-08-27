SELECT DATE_TRUNC('day', started_at) AS date,
       COUNT(DISTINCT subscriptions_events.analytics_id) AS count_subscriptions_events_users,
       COUNT(DISTINCT CASE WHEN sp_users.analytics_id IS NULL THEN subscriptions_events.analytics_id END) AS count_missing_analytics_id_in_sp_users
FROM der.subscriptions_events
LEFT JOIN der.sp_users USING (analytics_id)
WHERE platform = 'IOS' AND started_at >= '2023-01-01'
GROUP BY 1
ORDER BY 1 DESC
;