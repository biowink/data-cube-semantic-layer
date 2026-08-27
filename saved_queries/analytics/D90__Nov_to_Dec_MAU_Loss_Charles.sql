SELECT YEAR(session_start) AS year,
    COUNT(DISTINCT CASE WHEN MONTH(session_start) = 12 THEN analytics_id END) * 1.0/
        COUNT(DISTINCT CASE WHEN MONTH(session_start) = 11 THEN analytics_id END) - 1 AS nov_dec_mau_loss
FROM der.sessions
INNER JOIN der.users USING (analytics_id)
WHERE session_start >= DATE('2021-11-01')
    AND DAY(session_start) < 31
    AND MONTH(session_start) BETWEEN 11 AND 12
    AND DATE_DIFF('day', account_created_at, session_start) > 90
GROUP BY 1
ORDER BY 1
;