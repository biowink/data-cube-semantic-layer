SELECT date,
       COUNT(DISTINCT master_id) AS count_mau,
       COUNT(DISTINCT CASE WHEN platform = 'android' THEN master_id END) AS count_android_mau,
       COUNT(DISTINCT CASE WHEN platform = 'ios' THEN master_id END) AS count_ios_mau
FROM static.calendar
LEFT JOIN der.sessions ON DATEDIFF('day', session_start::DATE, date) BETWEEN 0 AND 29
WHERE date IN ('2022-12-31', '2023-01-31', '2023-02-28', '2023-03-13')
GROUP BY 1
ORDER BY 1
;