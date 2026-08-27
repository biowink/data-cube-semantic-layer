SELECT DATE_DIFF('year', birthday, date) AS age,
       COUNT(*),
        AVG(CASE WHEN type IN ('late', 'missed') THEN 1.0 else 0 END)
FROM der.backend_tracking
INNER JOIN der.profiles USING (analytics_id)
WHERE category = 'birth_control_pill'
    AND date BETWEEN DATE('2023-07-01') AND DATE('2024-06-30')
    AND DATE_DIFF('year', birthday, date) BETWEEN 13 AND 50
GROUP BY 1
ORDER BY 1
;