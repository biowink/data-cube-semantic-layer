SELECT cycle_end >= CURRENT_DATE AS cycle_end_in_future,
      cycle_start >= CURRENT_DATE AS cycle_start_in_future,
       cycle_predicted,
       current_cycle,
       COUNT(*) AS count
FROM der.backend_cycles
WHERE cycle_start >= '2023-01-01'
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4
;