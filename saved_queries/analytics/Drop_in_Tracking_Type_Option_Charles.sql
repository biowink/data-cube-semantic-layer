SELECT backend_updated_at::DATE, COUNT(DISTINCT type)
FROM der.backend_tracking
WHERE backend_updated_at >= CURRENT_DATE - 60 AND category != 'tags'
GROUP BY 1
ORDER BY 1
;