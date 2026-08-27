SELECT DATE_TRUNC('month', users.backend_created_at) AS month,
       COUNT(*) AS count,
       AVG(CASE WHEN birthday IS NOT NULL THEN 1::FLOAT ELSE 0 END)
FROM import.users
LEFT JOIN import.profiles USING (analytics_id)
WHERE users.backend_created_at >= '2022-01-01'
GROUP BY 1
ORDER BY 1 DESC
;