WITH dedup_subev AS (
    SELECT
        subscription_id,
        transaction_id,
        original_subscription_type AS type,
        product_id,
        platform,
        backend_created_at,
        backend_updated_at,
        user_id
    FROM intermediate.ios_clue_plus
    UNION ALL
    SELECT
        subscription_id,
        transaction_id,
        original_subscription_type AS type,
        product_id,
        platform,
        backend_created_at,
        backend_updated_at,
        user_id
    FROM intermediate.android_clue_plus
)
SELECT
    type,
    COUNT(clean.transaction_id) AS clean_count,
    COUNT(dedup_subev.transaction_id) AS raw_count,
    clean_count::FLOAT / raw_count AS clean_to_raw_ratio
FROM dedup_subev
LEFT JOIN import.subscriptions subs
        ON subs.id = dedup_subev.subscription_id
LEFT JOIN der.subscriptions_events clean
        ON (dedup_subev.transaction_id = clean.transaction_id)
WHERE
        type IN ('SUBSCRIPTION_CANCELED',
                 'SUBSCRIPTION_EXPIRED',
                 'SUBSCRIPTION_GRACE_PERIOD',
                 'SUBSCRIPTION_PURCHASED',
                 'SUBSCRIPTION_RECOVERED',
                 'SUBSCRIPTION_RENEWED',
                 'SUBSCRIPTION_REVOKED',
                 'SUBSCRIPTION_VALIDATED')
    AND subs.test_subscription IS FALSE
    AND dedup_subev.backend_created_at::DATE = '2022-11-16'
GROUP BY 1
ORDER BY 1
;