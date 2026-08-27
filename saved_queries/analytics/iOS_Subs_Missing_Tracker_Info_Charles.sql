SELECT
    DATE(account_created_at) AS date,
    AVG(CASE WHEN tracker_name IS NULL THEN 1.0 ELSE 0 END) AS missing_tracker,
    AVG(CASE WHEN tracker_name IS NULL AND COALESCE(partner, '') = 'oura' THEN 1.0 ELSE 0 END) AS missing_tracker_with_oura_sub,
    AVG(CASE WHEN tracker_name IS NULL AND COALESCE(partner, '') != 'oura' THEN 1.0 ELSE 0 END) AS missing_tracker_excluding_oura_sub,
    AVG(CASE WHEN LOWER(account_source) = 'web' THEN 1.0 ELSE 0 END) AS web_source_accounts
FROM der.users
INNER JOIN user_metrics.user_last_session_attributes USING (analytics_id)
LEFT JOIN der.backend_adjust_trackers USING (analytics_id)
INNER JOIN user_metrics.user_account_source USING (analytics_id)
LEFT JOIN der.subscription_history USING (analytics_id)
WHERE 
    user_last_session_attributes.platform = 'ios' 
    AND account_created_at BETWEEN DATE '2026-03-01' AND CURRENT_DATE
GROUP BY 1
ORDER BY 1
;