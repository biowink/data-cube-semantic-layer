SELECT DATE (session_start) AS date,
    FLOOR(session_length_Sec/5) AS session_length,
    COUNT (DISTINCT sp_device_id) AS device_count
FROM der.sessions
WHERE session_start >= DATE ('2024-09-01')
    AND platform = 'ios'
    AND analytics_id IS NULL
GROUP BY
    1, 2
ORDER BY 1, 2
;