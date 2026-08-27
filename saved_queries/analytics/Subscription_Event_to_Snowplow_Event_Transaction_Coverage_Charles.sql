SELECT subscriptions_events.platform,
       subscription_duration,
       COUNT(DISTINCT id) AS purchase_subscription_event_count,
       COUNT(DISTINCT json_extract_path_text(event_properties, 'Transaction Id')) AS snowplow_transaction_count,
       snowplow_transaction_count::FLOAT/purchase_subscription_event_count AS coverage_rate
FROM der.subscriptions_events
LEFT OUTER JOIN der.events ON json_extract_path_text(event_properties, 'Transaction Id') = transaction_id
                                  AND mobile_event_name = 'Subscription Started' AND derived_tstamp >= CURRENT_DATE - 40
WHERE subscription_type = 'Subscription Purchased' AND subscriptions_events.backend_created_at >= CURRENT_DATE - 30
GROUP BY 1, 2
ORDER BY 1, 2
;