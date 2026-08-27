SELECT DATE_TRUNC('day', account_created_at) AS date,
       COUNT(DISTINCT CASE WHEN count_exit_data_entry >0 THEN sessions.analytics_id END) * 1.0 /COUNT(DISTINCT users.analytics_id) AS d1_retention_rate
FROM der.users
INNER JOIN user_metrics.adjust_attribution attr ON users.analytics_id = attr.analytics_id
INNER JOIN user_metrics.user_first_session_attributes fsa ON users.analytics_id = fsa.analytics_id
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id 
                              AND DATE_DIFF('day', account_created_at, session_start) = 0 AND session_start >= DATE('2024-08-01')
WHERE attr.network = 'Organic' 
    AND fsa.platform = 'android' 
    AND account_created_at >= DATE('2024-08-01') 
    AND account_created_at < CURRENT_DATE - INTERVAL '1' DAY
GROUP BY 1
ORDER BY 1
;