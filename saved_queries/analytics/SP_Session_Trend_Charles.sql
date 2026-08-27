WITH sessions AS (
SELECT session_start::DATE AS date,
platform,
       COUNT(DISTINCT analytics_id) AS user_count,
       COUNT(DISTINCT sp_device_id) AS device_count
FROM der.sessions
WHERE session_start::DATE = min_collector_tstamp::DATE AND session_start >= CURRENT_DATE - 90
GROUP BY 1, 2
),
rolling_sessions AS (
SELECT date,
platform,
AVG(device_count) OVER (PARTITION BY platform ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_device_count
FROM sessions
)
SELECT * FROM rolling_sessions WHERE date >= '2023-08-01'
;