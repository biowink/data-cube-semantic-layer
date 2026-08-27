SELECT date,
       keyword,
       app,
       platform,
       country,
       language,
       COUNT(*) AS count,
       COUNT(DISTINCT etl_created_at)
FROM rep.keywords
WHERE date >= '2023-01-01'
GROUP BY 1, 2, 3, 4, 5, 6
ORDER BY 7 DESC
;