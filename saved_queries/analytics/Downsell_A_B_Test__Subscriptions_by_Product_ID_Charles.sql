WITH onboarding_buy_screen AS (
    SELECT
        root_id,
        analytics_id,
        derived_tstamp,
        app_version
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
    MIN(onboarding_buy_screen.derived_tstamp) AS TIMESTAMP
FROM
    onboarding_buy_screen INNER JOIN experiment_events
ON (onboarding_buy_screen.analytics_id = experiment_events.analytics_id AND onboarding_buy_screen.derived_tstamp BETWEEN experiment_events.derived_tstamp - INTERVAL '10' MINUTE AND experiment_events.derived_tstamp + INTERVAL '60' MINUTE)
GROUP BY
    1, 2, 3
    )
SELECT variation_id,
       product_id,
       COUNT(DISTINCT mobile_subscriptions_events.analytics_id) AS count_users
FROM assignment
INNER JOIN der.mobile_subscriptions_events ON assignment.analytics_id = mobile_subscriptions_events.analytics_id
WHERE subscription_type IN ('Subscription Free Trial', 'Subscription Purchased')
GROUP BY 1, 2
ORDER BY 1, 3 DESC
;