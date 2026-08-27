SELECT
    COUNT(DISTINCT sp_users.user_id) AS mau,
    COUNT(DISTINCT consent.user_id) AS revoked,
    revoked::FLOAT / mau AS share_mau_revoked
FROM der.sp_users
LEFT JOIN import.consent
        ON sp_users.user_id = consent.user_id AND revoke_timestamp IS NOT NULL AND consent_type = 'statistical-analysis'
WHERE
    last_seen >= CURRENT_DATE - 31
;