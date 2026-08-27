SELECT platform,
DATE(account_created_at) AS date,
       user_first_session_attributes.major_app_version,
       COUNT(analytics_id) AS count_users,
       AVG( CASE WHEN count_d1_sessions > 0 THEN 1.0 ELSE 0 END) AS d1_retention
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
INNER JOIN user_metrics.new_user_retention_metrics USING (analytics_id)
WHERE 
    account_created_at >= CURRENT_DATE - INTERVAL '90' DAY
    AND account_created_at < CURRENT_DATE - INTERVAL '1' DAY
    AND platform = 'android'
GROUP BY 1, 2, 3
HAVING COUNT(analytics_id) > 1000
ORDER BY 1, 2, 3
;
