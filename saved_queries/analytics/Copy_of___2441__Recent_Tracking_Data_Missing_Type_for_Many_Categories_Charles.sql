SELECT category, type, COUNT(*)
FROM der.backend_tracking
WHERE backend_updated_at >= CURRENT_DATE - 7
GROUP BY 1, 2
ORDER BY 1, 2
;