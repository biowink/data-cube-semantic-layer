WITH backend_method AS (
SELECT
    DATE_TRUNC('month', account_created_at) AS month,
    user_first_session_attributes.platform,
    AVG(CASE WHEN count_d7_tracking_days >= 2 AND count_d7_tracking_points >= 5 THEN 1.0 ELSE 0 END) AS backend_calculation
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes
    ON users.analytics_id = user_first_session_attributes.analytics_id
INNER JOIN user_metrics.new_user_activation_metrics
    ON users.analytics_id = new_user_activation_metrics.analytics_id
WHERE
    account_created_at BETWEEN DATE '2025-01-01' AND DATE '2026-01-01'
    AND user_first_session_attributes.platform IS NOT NULL
GROUP BY 1, 2
),
    client_method AS (
SELECT
    DATE_TRUNC('month', account_created_at) AS month,
    user_first_session_attributes.platform,
    users.analytics_id,
    SUM(CAST(NULLIF(JSON_EXTRACT_SCALAR(LOWER(event_properties), '$["number of added data points"]'), '') AS INT)) AS tracking_points,
    COUNT(CASE WHEN mobile_event_name = 'Exit Multi Day Tracker' THEN 1 ELSE 0 END) AS multi_tracker_usages,
    COUNT(root_id) AS count_events,
    COUNT(DISTINCT DATE(derived_tstamp)) AS tracking_days
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes
    ON users.analytics_id = user_first_session_attributes.analytics_id
LEFT JOIN der.events
    ON events.analytics_id = users.analytics_id
    AND mobile_event_name IN ('Exit Data Entry', 'Exit Multi Day Tracker', 'Exit Daily Check In Tracking')
    AND derived_tstamp >= DATE '2025-01-01'
    AND DATE_DIFF('day', DATE(account_created_at), DATE(derived_tstamp)) BETWEEN 0 AND 7
WHERE
    account_created_at BETWEEN DATE '2025-01-01' AND DATE '2026-01-01'
    AND user_first_session_attributes.platform IS NOT NULL
GROUP BY 1, 2, 3
    ),
    client_method_agg AS (
    SELECT
        month,
        platform,
        AVG(CASE WHEN (COALESCE(tracking_points, 0)) >= 5
            AND tracking_days >= 2 THEN 1.0 ELSE 0 END) AS client_calculation_1,
        AVG(CASE WHEN (COALESCE(tracking_points, 0) + COALESCE(multi_tracker_usages, 0)) >= 5
            AND tracking_days >= 2 THEN 1.0 ELSE 0 END) AS client_calculation_2,
        AVG(CASE WHEN (COALESCE(tracking_points, 0) + COALESCE(multi_tracker_usages, 0) * 2) >= 5
            AND tracking_days >= 2 THEN 1.0 ELSE 0 END) AS client_calculation_3,
        AVG(CASE WHEN count_events >= 3
            AND tracking_days >= 2 THEN 1.0 ELSE 0 END) AS client_calculation_4
    FROM client_method
    GROUP BY 1, 2
    )
SELECT
    month,
    platform,
    backend_calculation,
    client_calculation_1,
    client_calculation_2,
    client_calculation_3,
    client_calculation_4
FROM backend_method
LEFT JOIN client_method_agg USING (month, platform)
WHERE platform = 'ios'
ORDER BY 1, 2
;