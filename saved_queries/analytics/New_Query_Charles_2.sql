SELECT
    DATE(publish_tstamp) AS date,
    COUNT(*) AS count_events
FROM der.backend_abfeature_evaluated_events
WHERE publish_tstamp >= DATE '2026-06-01'
GROUP BY 1
ORDER BY 1
;