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
SELECT CASE WHEN share_days_with_prediction > 0.5 THEN '>50%'
        ELSE CAST((CAST(CEILING(share_days_with_prediction*20) AS INT) - 1) * 5 + 1 AS VARCHAR) || '%-' ||
            CAST(CAST(CEILING(share_days_with_prediction*20) AS INT) * 5 AS VARCHAR) || '%'
        END AS share_days_with_prediction,
        MAX(share_days_with_prediction) AS top_bound,
       COUNT(DISTINCT prediction_checkers.analytics_id) AS count_users,
       ((COUNT(backend_tracking.date) * 1.0)/90)/COUNT(DISTINCT prediction_checkers.analytics_id) AS share_past_days_with_cramps_tracking
FROM prediction_checkers
LEFT JOIN der.backend_tracking ON prediction_checkers.analytics_id = backend_tracking.analytics_id AND backend_tracking.date BETWEEN DATE '2025-01-01' AND DATE '2025-10-01'
    AND DATE_DIFF('day', DATE(backend_tracking.date), DATE(prediction_checkers.derived_tstamp)) BETWEEN 1 AND 90
    AND category = 'pain' AND backend_tracking.type = 'period_cramps'
WHERE rnk = 1
GROUP BY 1
ORDER BY 2
;