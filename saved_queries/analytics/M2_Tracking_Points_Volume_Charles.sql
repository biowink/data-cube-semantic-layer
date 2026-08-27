SELECT platform,
       DATE_TRUNC('month', account_created_at) AS account_created_month,
       COUNT(DISTINCT backend_tracking.analytics_id)::FLOAT/
       COUNT(DISTINCT users.analytics_id) AS m2_tracking_rate
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
LEFT JOIN der.backend_tracking ON users.analytics_id = backend_tracking.analytics_id AND backend_tracking.backend_updated_at >= '2023-01-01'
    AND backend_tracking.backend_updated_at::DATE - account_created_at::DATE BETWEEN 31 AND 60
WHERE account_created_at BETWEEN '2023-01-01' AND '2023-06-30'
AND major_app_version > 100
GROUP BY 1, 2
ORDER BY 1, 2
;