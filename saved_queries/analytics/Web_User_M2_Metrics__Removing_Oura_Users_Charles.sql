SELECT DATE_TRUNC('week', account_created_at) AS week,
       AVG(CASE WHEN count_d7_tracking_points >= 5 AND count_d7_tracking_days >= 2 THEN 1.0 ELSE 0 END) AS share_activating,
       AVG(CASE WHEN count_m2_tracking_days > 0 THEN 1.0 ELSE 0 END) AS share_m2_tracking_retained,
       AVG(CASE WHEN count_m2_active_days > 0 THEN 1.0 ELSE 0 END) AS share_m2_mau_retained
FROM der.users
INNER JOIN user_metrics.new_user_activation_metrics USING (analytics_id)
INNER JOIN user_metrics.new_user_retention_metrics USING (analytics_id)
INNER JOIN user_metrics.user_account_source USING (analytics_id)
LEFT JOIN (SELECT DISTINCT analytics_id, subscription_type 
        FROM der.all_subscriptions_events 
        WHERE partner = 'oura' AND subscription_type = 'Subscription Granted') AS oura_users USING (analytics_id)
WHERE account_created_at BETWEEN DATE '2024-05-20' AND DATE '2024-10-01'
    AND CASE WHEN (((CASE WHEN user_account_source.account_source in ('Android', 'iOS')
              THEN 'App'
              ELSE COALESCE(user_account_source.account_source, 'Web')
              END)) = 'Web') THEN 'Web' ELSE 'App' END = 'Web'
              AND subscription_type IS NULL
GROUP BY 1
ORDER BY 1
;