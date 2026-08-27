SELECT DATE_TRUNC('day', account_created_at) AS date, 
platform,
COUNT(*) AS count_users, 
AVG(count_d0_period_tracking_points * 1.0) AS avg_period_tracking_points,
       AVG((count_d0_tracking_points - count_d0_period_tracking_points) * 1.0) AS avg_nonperiod_tracking_points
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
INNER JOIN user_metrics.new_user_activation_metrics USING (analytics_id)
WHERE platform IS NOT NULL AND account_created_at >= DATE('2024-03-01')
GROUP BY 1, 2
ORDER BY 1, 2
;