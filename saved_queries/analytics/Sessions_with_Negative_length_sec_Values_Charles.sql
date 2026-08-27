SELECT DATE_TRUNC('month', start::DATE) AS month,
       COUNT(*) AS count_sessions,
       AVG(length_sec) AS avg_length_sec
FROM der.sp_sessions
WHERE length_sec < -2
GROUP BY 1
ORDER BY 1
;