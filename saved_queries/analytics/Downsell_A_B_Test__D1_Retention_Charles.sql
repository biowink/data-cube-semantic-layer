WITH onboarding_buy_screen AS (
    SELECT
        root_id,
        analytics_id,
        derived_tstamp,
        app_version,
        session_id
    FROM der.events
    WHERE
        mobile_event_name = 'View Subscription Plans'
        AND navigation_context = 'onboarding'
        AND derived_tstamp >= DATE('2024-11-01')
),
experiment_events AS (
    SELECT
        analytics_id,
        derived_tstamp,
        JSON_EXTRACT_SCALAR(event_properties, '$["abfeature_evaluated.ab_feature.experiment_name"]') as experiment_name,
        JSON_EXTRACT_SCALAR(event_properties, '$["abfeature_evaluated.ab_feature.variant_id"]') as variant_id,
        JSON_EXTRACT_SCALAR(event_properties, '$["abfeature_evaluated.ab_feature.variant_name"]') as variant_name
    FROM der.events
    WHERE
        mobile_event_name = 'Abfeature Evaluated'
        AND derived_tstamp >= DATE('2024-11-01')
),
        assignment AS (
SELECT
    onboarding_buy_screen.analytics_id,
    experiment_events.experiment_name AS experiment_id,
    experiment_events.variant_id AS variation_id,
    onboarding_buy_screen.session_id AS session_id,
    MIN(onboarding_buy_screen.derived_tstamp) AS experiment_timestamp
FROM
    onboarding_buy_screen
INNER JOIN experiment_events
ON (onboarding_buy_screen.analytics_id = experiment_events.analytics_id AND onboarding_buy_screen.derived_tstamp BETWEEN experiment_events.derived_tstamp - INTERVAL '10' MINUTE AND experiment_events.derived_tstamp + INTERVAL '60' MINUTE)
GROUP BY
    1, 2, 3, 4
    )
SELECT variation_id,
       COUNT(DISTINCT assignment.analytics_id) AS count_users,
       COUNT(DISTINCT sessions.analytics_id) AS count_d1_retained,
       COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT assignment.analytics_id) AS d1_retention_rate
FROM assignment
LEFT JOIN der.sessions ON assignment.analytics_id = sessions.analytics_id
                              AND DATE(session_start) = DATE(experiment_timestamp) + INTERVAL '1' DAY
                              AND session_start >= DATE('2024-11-01')
WHERE DATE(experiment_timestamp) < CURRENT_DATE - INTERVAL '1' DAY
GROUP BY 1
ORDER BY 1
;