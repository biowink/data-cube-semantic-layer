SELECT 
    date(session_start) AS date,
    sp_device_id,
    COUNT(*) AS count_sessions
FROM der.sessions
WHERE analytics_id = 'clue-a0343945de7e1777009ec934bccb763'
    AND session_start >= DATE '2025-01-01'
GROUP BY 1, 2
ORDER BY 1, 2
;