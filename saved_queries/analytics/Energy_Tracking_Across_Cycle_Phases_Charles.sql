SELECT cycle_phase,
       tracking_option,
       COUNT(*)
FROM temp.mind_energy_cycle_tracking
WHERE did_track_energy
  AND tracking_category = 'energy'
  AND tracking_option != ''
  AND cycle_phase IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;