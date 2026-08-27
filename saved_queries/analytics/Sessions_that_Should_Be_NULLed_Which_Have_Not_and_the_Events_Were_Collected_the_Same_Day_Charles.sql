SELECT DATE(session_start) AS date,
    COUNT(*) AS problematic_session_count
FROM der.sessions
LEFT JOIN user_metrics.revoke_usage_analytics_user USING (analytics_id)
WHERE session_start > consent_usage_analytics_revoke_ts
  AND session_length_sec IS NOT NULL
  AND session_start >= DATE('2023-01-01')
  AND DATE(session_start) = DATE(max_collector_tstamp)
GROUP BY 1
ORDER BY 1 DESC
;