WITH flash_sale_purchases AS (
    SELECT
        analytics_id,
        backend_created_at
    FROM der.mobile_subscriptions_events
    WHERE
        platform = 'IOS'
        AND subscription_type = 'Subscription Purchased'
        AND original_subscription_type = 'Subscription Purchased'
        AND backend_created_at >= DATE '2024-01-01'
        AND is_in_intro_offer_period
--         AND NOT reactivation
    ),
    subscription_starts AS (
        SELECT analytics_id,
               derived_tstamp
        FROM der.events
        WHERE 
            platform = 'ios'
            AND mobile_event_name = 'Subscription Started'
            AND derived_tstamp >= DATE '2024-01-01'
    )
SELECT 
    DATE_TRUNC('month', backend_created_at) AS month,
    COUNT(DISTINCT subscription_starts.analytics_id) * 1.0/
        COUNT(DISTINCT flash_sale_purchases.analytics_id) AS share_flash_sale_subs_missing_client_event
FROM flash_sale_purchases
LEFT JOIN subscription_starts ON flash_sale_purchases.analytics_id = subscription_starts.analytics_id
    AND DATE(backend_created_at) = DATE(derived_tstamp)
GROUP BY 1
ORDER BY 1
;