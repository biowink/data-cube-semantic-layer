SELECT EXTRACT('month' from birthday) || '-' || EXTRACT('day' from birthday),
       COUNT(*)
FROM der.profiles
INNER JOIN der.users USING (analytics_id)
WHERE backend_created_at BETWEEN '2022-06-20' AND '2022-07-30' AND birthday IS NOT NULL
GROUP BY 1
ORDER BY 1
;