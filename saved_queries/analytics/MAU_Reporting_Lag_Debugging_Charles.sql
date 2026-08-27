SELECT date, 'full refresh' AS source, SUM(count_mau) AS count_mau
FROM temp.active_user_trends_refresh_20230814
WHERE date >= '2023-05-01'
GROUP BY 1, 2
UNION ALL
SELECT date, 'incremental' AS source, SUM(count_mau) AS count_mau
FROM rep.active_user_trends
WHERE date >= '2023-05-01'
GROUP BY 1, 2
ORDER BY 1 DESC, 2
;