SELECT backend_created_at::DATE,
       COUNT(DISTINCT user_id)
FROM der.tracking
WHERE backend_created_at >= '2022-03-01' AND category = 'sex'
GROUP BY 1
ORDER BY 1
;