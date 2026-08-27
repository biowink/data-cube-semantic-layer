SELECT DATE_DIFF('year', birthday, DATE '2025-06-01') AS age,
       COUNT(DISTINCT CASE WHEN type = 'joint' THEN backend_tracking.analytics_id END) * 1.0/COUNT(DISTINCT users.analytics_id) AS share_tracking_joint_pain
FROM der.users
INNER JOIN der.profiles ON profiles.analytics_id = users.analytics_id
-- INNER JOIN user_metrics.user_last_session_attributes ON user_last_session_attributes.analytics_id = users.analytics_id
INNER JOIN user_metrics.user_last_optional_consent_status
    ON user_last_optional_consent_status.analytics_id = users.analytics_id
INNER JOIN der.backend_tracking ON backend_tracking.analytics_id = users.analytics_id
    AND backend_tracking.backend_updated_at >= DATE '2025-06-01'
    AND backend_tracking.backend_updated_at < DATE '2025-07-01'
    -- AND category = 'pain' AND type = 'joint'
WHERE
   consent_scientific_research
    AND consent_health_analytics
    AND consent_usage_analytics
    AND DATE_DIFF('year', birthday, DATE '2025-06-01') BETWEEN 13 AND 50
GROUP BY 1
ORDER BY 1
;