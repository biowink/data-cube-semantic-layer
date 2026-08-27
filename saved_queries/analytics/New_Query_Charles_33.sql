SELECT DATE_TRUNC('week', backend_updated_at) AS week,
       category = 'period' AS is_period,
       COUNT(*) AS count_tracking_points
FROM der.backend_tracking
INNER JOIN user_metrics.user_last_session_attributes USING (analytics_id)
WHERE platform = 'android'
AND revision_type = 'measurements_tracked' 
AND backend_updated_at >= DATE '2024-10-01'
GROUP BY 1, 2
ORDER BY 1, 2
;