SELECT major_app_version,
       COUNT(*),
       AVG(count_d7_tracking_points * 1.0) AS count_d7_tracking_points,
       AVG(count_d7_tracking_days * 1.0) AS count_d7_tracking_days,
       AVG(count_d0_tracking_points * 1.0) AS count_d0_tracking_points,
       AVG((count_d7_tracking_points - count_d0_tracking_points) * 1.0) AS count_later_tracking_points,
       AVG(count_d7_active_days * 1.0) AS count_d7_active_days,
       AVG(new_user_activation_metrics.count_d7_sessions * 1.0) AS count_d7_sessions,
       AVG(count_d7_tracking_categories * 1.0) AS count_d7_tracking_categories,
       AVG(count_d7_view_subscription_plans * 1.0) AS count_d7_view_subscription_plans
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
INNER JOIN user_metrics.new_user_activation_metrics USING (analytics_id)
INNER JOIN user_metrics.new_user_retention_metrics USING (analytics_id)
INNER JOIN user_metrics.adjust_attribution USING (analytics_id)
WHERE platform = 'android'
    AND major_app_version >= 190
    AND account_created_at >= DATE '2025-05-01'
    AND account_created_at < CURRENT_DATE - INTERVAL '7' DAY
    AND network = 'Organic'
GROUP BY 1
HAVING COUNT(*) > 5000
ORDER BY 1
;