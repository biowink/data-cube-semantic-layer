WITH device_counts AS (
    SELECT DATE (session_start) AS date,
    analytics_id,
    COUNT (DISTINCT sp_device_id) AS device_count
FROM der.sessions
WHERE session_start >= DATE ('2024-08-01')
    AND platform = 'ios'
    AND analytics_id IS NOT NULL
GROUP BY
    1, 2
)
SELECT date,
    COUNT(*)
FROM device_counts
WHERE device_count > 1
GROUP BY 1
ORDER BY 1
;