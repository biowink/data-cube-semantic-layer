WITH prediction_checkers AS (
SELECT analytics_id,
       derived_tstamp,
       CAST(NULLIF(JSON_EXTRACT_SCALAR(event_properties, '$["Number of Prediction Days"]'), '') AS INT) AS number_of_predicted_days,
       DATE_DIFF('day', DATE(derived_tstamp), DATE_TRUNC('month',DATE_ADD('month', 2, DATE(derived_tstamp)))) - 1 AS possible_days,
       CAST(NULLIF(JSON_EXTRACT_SCALAR(event_properties, '$["Number of Prediction Days"]'), '') AS INT) * 1.0/
        (DATE_DIFF('day', DATE(derived_tstamp), DATE_TRUNC('month',DATE_ADD('month', 2, DATE(derived_tstamp)))) - 1) AS share_days_with_prediction,
        ROW_NUMBER() OVER (PARTITION BY analytics_id ORDER BY derived_tstamp) AS rnk
FROM der.events
WHERE derived_tstamp BETWEEN DATE '2025-09-01' AND DATE '2025-09-15'
    AND mobile_event_name = 'Show Cramps Prediction Screen'
    AND CAST(NULLIF(JSON_EXTRACT_SCALAR(event_properties, '$["Number of Prediction Days"]'), '') AS INT) > 0
)
SELECT LEAST(CEILING(number_of_predicted_days * 1.0/2), 9) AS number_of_predicted_days,
       COUNT(DISTINCT prediction_checkers.analytics_id) AS count_users,
       COUNT(DISTINCT session_id) * 1.0/COUNT(DISTINCT prediction_checkers.analytics_id) AS revisit_sessions
FROM prediction_checkers
LEFT JOIN der.events ON prediction_checkers.analytics_id = events.analytics_id AND events.derived_tstamp >= DATE '2025-09-01'
    AND DATE_DIFF('day', DATE(prediction_checkers.derived_tstamp), DATE(events.derived_tstamp)) BETWEEN 1 AND 14
    AND mobile_event_name = 'Show Cramps Prediction Screen'
WHERE rnk = 1
GROUP BY 1
ORDER BY 1
;