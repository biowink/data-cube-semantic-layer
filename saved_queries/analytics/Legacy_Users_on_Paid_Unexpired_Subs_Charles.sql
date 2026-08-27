SELECT user_last_session_attributes.platform,
       COUNT(DISTINCT CASE WHEN is_purchased AND NOT is_expired THEN analytics_id END)
FROM user_metrics.user_last_session_attributes
LEFT JOIN der.subscription_history USING (analytics_id)
WHERE major_app_version < 100
GROUP BY 1
ORDER BY 1
;