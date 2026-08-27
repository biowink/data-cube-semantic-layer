WITH rates AS (
SELECT date,
country_name,
       COUNT(DISTINCT CASE WHEN type = 'anxious' THEN analytics_id END) AS count_anxious,
       COUNT(DISTINCT analytics_id) AS count_tracking,
       count_anxious::FLOAT/count_tracking AS share_tracking_anxious
FROM der.backend_tracking
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
WHERE date >= '2024-01-01' AND country_name IN ('United Kingdom', 'France', 'Germany', 'United States') AND date = backend_updated_at::DATE
  AND revision_type = 'measurements_tracked' AND category = 'feelings'
GROUP BY 1, 2
ORDER BY 2, 1
)
SELECT date,
country_name,
AVG(share_tracking_anxious) OVER (PARTITION BY country_name ORDER BY DATE ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_anxious_rate
FROM rates

;