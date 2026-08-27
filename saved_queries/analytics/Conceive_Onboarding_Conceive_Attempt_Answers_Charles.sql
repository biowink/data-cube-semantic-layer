WITH indexed_conceive_attempt_answers AS (
SELECT
    COALESCE(events.analytics_id, user_onboarding_funnel.analytics_id) AS analytics_id,
    events.platform,
    events.derived_tstamp,
    JSON_EXTRACT_SCALAR(event_properties, '$["Attempt Timespan"]') AS attempt_timespan,
    ROW_NUMBER()
        OVER (PARTITION BY COALESCE(events.analytics_id, user_onboarding_funnel.analytics_id)
                ORDER BY events.derived_tstamp DESC) AS rnk
FROM der.events
LEFT JOIN user_metrics.user_onboarding_funnel USING (sp_device_id)
WHERE
    mobile_event_name IN ('Answer Conceive Attempt Timespan', 'Answer Conceive Attempt Timestamp')
    AND derived_tstamp >= DATE '2023-01-01'
    AND events.major_app_version > 100
    AND COALESCE(events.analytics_id, user_onboarding_funnel.analytics_id) IS NOT NULL
    AND JSON_EXTRACT_SCALAR(event_properties, '$["Attempt Timespan"]') != ''
)
SELECT
    analytics_id,
    platform,
    derived_tstamp,
    attempt_timespan
FROM indexed_conceive_attempt_answers
WHERE rnk = 1
LIMIT 500
;