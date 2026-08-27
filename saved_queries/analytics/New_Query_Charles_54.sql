SELECT DATE_TRUNC('hour', backend_updated_at),
       COUNT(*)
FROM der.backend_tracking
WHERE backend_updated_at >= CURRENT_DATE - 4
GROUP BY 1
ORDER BY 1 DESC
;
