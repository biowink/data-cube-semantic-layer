SELECT category, type, COUNT(*)
FROM der.tracking
WHERE date >= CURRENT_DATE - 90
GROUP BY 1, 2
ORDER BY 3 DESC
;