WITH cancellation_attempts AS (
SELECT
    event_properties,
    JSON_EXTRACT_SCALAR(event_properties, '$.userId') AS analytics_id,
    JSON_EXTRACT_SCALAR(event_properties, '$.eventId') AS event_id,
    JSON_EXTRACT_SCALAR(event_properties, '$.appstoreCancellationAttempted.request.productId') AS product_id,
    JSON_EXTRACT_SCALAR(event_properties, '$.appstoreCancellationAttempted.request.userLocale') AS locale,
    JSON_EXTRACT_SCALAR(event_properties, '$.publishTime') AS derived_tstamp
FROM import.com_helloclue_backend_events_1
WHERE run_date >= DATE '2026-05-01'
AND event_name = 'appstore_cancellation_attempted'
),
    accepted_offers AS (
SELECT
    json_extract_scalar(document, '$.renewal_info.offerIdentifier') AS offer_identifier,
    from_unixtime(CAST(json_extract_scalar(document, '$.renewal_info.signedDate') AS DOUBLE) / 1000) AS signed_tstamp,
    json_extract_scalar(document, '$.user_id') AS user_id
FROM
    import.backend_appstore_client_transactions
WHERE
    json_extract_scalar(document, '$.renewal_info.offerType') IS NOT NULL
    AND json_extract_scalar(document, '$.renewal_info.productId') = 'com.helloclue.clue.pro.sub.12m.v25'
),
    accepted_offers_locale AS (
    SELECT
        analytics_id,
        offer_identifier,
        signed_tstamp,
        locale
    FROM accepted_offers
    INNER JOIN core.clue_users USING (user_id)
    INNER JOIN user_metrics.user_last_session_attributes USING (analytics_id)
)
SELECT
    cancellation_attempts.locale,
    COUNT(DISTINCT cancellation_attempts.analytics_id) AS cancellation_attempts,
    COUNT(DISTINCT CASE WHEN signed_tstamp >= DATE(from_iso8601_timestamp(derived_tstamp))
          THEN accepted_offers_locale.analytics_id END) AS discount_offers_accepted
FROM cancellation_attempts
LEFT JOIN accepted_offers_locale ON cancellation_attempts.analytics_id = accepted_offers_locale.analytics_id
WHERE
    cancellation_attempts.locale IN ('en-US', 'en-AU', 'en-CA', 'en-GB',
'de-DE', 'fr-FR', 'fr-CA', 'pt-PT', 'pt-BR', 'es-ES', 'es-MX')
    AND from_iso8601_timestamp(derived_tstamp) >= DATE '2026-05-06'
    AND product_id = 'com.helloclue.clue.pro.sub.12m.v25'
GROUP BY 1
ORDER BY 1
;