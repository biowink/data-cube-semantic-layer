SELECT
    DATE(account_created_at) AS date,
    COUNT(*) AS count_revoked_consents
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
INNER JOIN import.backend_users_raw USING (analytics_id)
INNER JOIN airbyte.backend_consents_updated_events
    ON backend_users_raw.id = backend_consents_updated_events.user_id
WHERE
    consent_type = 'CONSENT_TYPE_USAGE_ANALYTICS'
    AND NOT enabled
    AND account_created_at >= DATE '2026-01-01'
    AND platform = 'android'
    AND backend_consents_updated_events.updated_at >= DATE '2025-12-01'
GROUP BY 1
ORDER BY 1
;