SELECT DAY_OF_WEEK(cycle_start) AS cycle_start_day_of_week,
       COUNT(*) AS count_cycles
FROM der.backend_cycles
WHERE 
    NOT cycle_predicted 
    AND NOT cycle_excluded
    AND cycle_start BETWEEN DATE '2024-10-01' AND DATE '2025-09-30'
GROUP BY 1
ORDER BY 2 DESC
;