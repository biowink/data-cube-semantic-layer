WITH experiment_begin AS (
SELECT
    analytics_id,
    JSON_EXTRACT_SCALAR(event_properties, '$.variant_id') AS variant_id,
    MIN(derived_tstamp) AS experiment_start
FROM der.events
WHERE
    derived_tstamp >= DATE '2026-08-13'
    AND mobile_event_name = 'Enter Experiment'
    AND JSON_EXTRACT_SCALAR(event_properties, '$.experiment_name') = 'compact_tracking_ios'
GROUP BY 1, 2
)
SELECT
    variant_id,
    navigation_context,
    COUNT(*) AS count_subscriptions
FROM experiment_begin
INNER JOIN der.events USING (analytics_id)
WHERE
    derived_tstamp >= DATE '2026-08-13'
    AND mobile_event_name = 'Subscription Started'
    AND experiment_start > derived_tstamp
GROUP BY 2, 1
ORDER BY 2, 1
;