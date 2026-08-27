SELECT DATE(session_start) AS date,
    DATE(session_start) = DATE(max_collector_tstamp) AS same_day,
    COUNT(*) AS problematic_session_count
FROM der.sessions
LEFT JOIN user_metrics.revoke_usage_analytics_user USING (analytics_id)
WHERE session_start > consent_usage_analytics_revoke_ts
  AND session_length_sec IS NOT NULL
  AND session_start >= DATE('2023-01-01')
GROUP BY 1,2
ORDER BY 1,2 DESC
;