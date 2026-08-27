SELECT
    DATE_TRUNC('quarter', cohort_month) AS cohort_quarter,
    lifecycle_month,
    AVG(avg_tracking_points) AS avg_tracking_points
FROM (SELECT
    DATE_TRUNC('month', backend_created_at) AS cohort_month,
    DATE_DIFF('month', DATE_TRUNC('month', clue_users.backend_created_at), DATE_TRUNC('month', derived_tstamp)) AS lifecycle_month,
    COUNT(*) * 1.0/COUNT(DISTINCT analytics_id) AS avg_tracking_points
FROM der.events
INNER JOIN core.clue_users USING (analytics_id)
WHERE
    mobile_event_name = 'Enter Data Point'
    AND (derived_tstamp BETWEEN DATE '2023-07-01' AND DATE '2026-07-01')
    AND backend_created_at >= DATE '2016-01-01'
GROUP BY 1, 2
)
GROUP BY 1, 2
ORDER BY 1, 2
;