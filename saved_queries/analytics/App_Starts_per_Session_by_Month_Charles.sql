WITH buy_screens AS (
SELECT session_id,
       platform,
       MIN(derived_tstamp) AS tstamp,
       COUNT(*) AS count_app_opens
FROM der.events
WHERE
    mobile_event_name = 'App Start'
    AND derived_tstamp >= DATE '2024-03-01'
GROUP BY 1, 2
)
SELECT DATE_TRUNC('month', tstamp) AS month,
platform,
AVG(count_app_opens * 1.0) AS avg_app_opens
FROM buy_screens
GROUP BY 1, 2
ORDER BY 1, 2
