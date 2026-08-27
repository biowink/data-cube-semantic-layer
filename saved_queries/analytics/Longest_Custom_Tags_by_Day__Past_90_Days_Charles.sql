SELECT LENGTH(type),
type
FROM der.backend_tracking
WHERE analytics_id = 'clue-c558584bed423bb9ad18087be219fb7'
AND backend_updated_at >= CURRENT_DATE - 7 AND category = 'tags'
ORDER BY 1 DESC
;

SELECT backend_updated_at::DATE,
MAX(LENGTH(type))
FROM der.backend_tracking
WHERE backend_updated_at >= CURRENT_DATE - 90 AND category = 'tags'
GROUP BY 1
ORDER BY 1 DESC
;