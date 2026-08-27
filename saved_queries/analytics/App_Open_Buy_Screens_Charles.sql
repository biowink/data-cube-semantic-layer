WITH buy_screens AS (
SELECT session_id,
       platform,
       MIN(derived_tstamp) AS tstamp,
       COUNT(*) AS count_buy_screens
FROM der.events
WHERE
    mobile_event_name = 'View Subscription Plans'
    AND navigation_context = 'app open'
    AND derived_tstamp >= DATE '2024-03-01'
GROUP BY 1, 2
)
SELECT DATE_TRUNC('month', tstamp) AS month,
platform,
AVG(CASE WHEN count_buy_screens > 1 THEN 1.0 ELSE 0 END) AS share_multiple
FROM buy_screens
GROUP BY 1, 2
ORDER BY 1, 2
