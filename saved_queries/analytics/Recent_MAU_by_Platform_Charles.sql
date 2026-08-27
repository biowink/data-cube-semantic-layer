SELECT date,
       platform,
       COUNT(DISTINCT master_id) AS mau
FROM static.calendar
LEFT JOIN der.sessions ON DATEDIFF('day', sessions.session_start, calendar.date) BETWEEN 0 AND 29
WHERE calendar.date BETWEEN '2023-01-01' AND CURRENT_DATE - 1 AND day_of_week = 1
GROUP BY 1, 2
ORDER BY 1, 2
;