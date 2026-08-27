SELECT
    DATE(account_created_at) AS date,
    COUNT(DISTINCT users.analytics_id) AS user_count,
    COUNT(DISTINCT CASE WHEN event_name = 'email_verified' THEN users.analytics_id END) * 1.0/COUNT(DISTINCT users.analytics_id) AS verified_rate_event,
    COUNT(DISTINCT CASE WHEN email_is_verified THEN users.analytics_id END) * 1.0/COUNT(DISTINCT users.analytics_id) AS verified_rate_backend,
    COUNT(DISTINCT CASE WHEN event_name = 'email_verification_requested' THEN users.analytics_id END) * 1.0/COUNT(DISTINCT users.analytics_id) AS request_rate_event
FROM der.users
INNER JOIN user_metrics.user_onboarding_funnel ON users.analytics_id = user_onboarding_funnel.analytics_id
LEFT JOIN import.com_helloclue_backend_events_1 ON JSON_EXTRACT_SCALAR(event_properties, '$.userId') = users.analytics_id
    AND event_name IN ('email_verified', 'email_verification_requested')
    AND run_date >= DATE '2026-01-01'
    AND DATE_DIFF('hour', account_created_at, from_iso8601_timestamp(JSON_EXTRACT_SCALAR(event_properties, '$.publishTime'))) <= 48
WHERE account_created_at BETWEEN DATE '2025-01-22' AND CURRENT_DATE - INTERVAL '2' DAY
    AND did_create_account_method = 'email'
GROUP BY 1
ORDER BY 1
;