SELECT count_d30_tracking_categories,
       COUNT(*) AS count_users,
       AVG(count_d30_tracking_points * 1.0) AS avg_tracking_points
FROM der.users
INNER JOIN user_metrics.new_user_activation_metrics USING (analytics_id)
WHERE account_created_at Between DATE '2024-01-01' AND DATE '2025-01-01'
GROUP BY 1
ORDER BY 1
;