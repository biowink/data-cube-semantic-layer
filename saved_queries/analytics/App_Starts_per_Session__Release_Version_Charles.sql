WITH buy_screens AS (
SELECT session_id,
       platform,
       major_app_version,
       MIN(derived_tstamp) AS tstamp,
       COUNT(*) AS count_app_opens
FROM der.events
WHERE
    mobile_event_name = 'App Start'
    AND derived_tstamp >= DATE '2025-03-01'
GROUP BY 1, 2, 3
)
SELECT major_app_version,
platform,
COUNT(*) AS count_sessions,
AVG(CASE WHEN count_app_opens > 1 THEN 1.0 ELSE 0 END) AS avg_app_opens
FROM buy_screens
GROUP BY 1, 2
HAVING COUNT(*) > 10000
ORDER BY 1, 2
