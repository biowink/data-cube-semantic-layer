SELECT backend_created_at::DATE AS backend_created_dt,
       COUNT(DISTINCT category) AS count_distinct_categories,
       COUNT(DISTINCT type) AS count_distinct_types
FROM der.tracking
WHERE backend_created_at >= '2023-01-01'
GROUP BY 1
ORDER BY 1
;