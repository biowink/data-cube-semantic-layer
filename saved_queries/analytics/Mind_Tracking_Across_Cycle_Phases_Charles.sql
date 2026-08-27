SELECT cycle_phase,
       SUM(CASE WHEN tracking_option = 'productive' THEN 1.0 END)/
       SUM(CASE WHEN tracking_option = 'unproductive' THEN 1 END) AS relative_productive_rate,
       SUM(CASE WHEN tracking_option = 'motivated' THEN 1.0 END)/
       SUM(CASE WHEN tracking_option = 'unmotivated' THEN 1 END) AS relative_motivated_rate,
       SUM(CASE WHEN tracking_option = 'calm' THEN 1.0 END)/
       SUM(CASE WHEN tracking_option = 'stressed' THEN 1 END) AS relative_calm_rate,
       SUM(CASE WHEN tracking_option = 'focused' THEN 1.0 END)/
       SUM(CASE WHEN tracking_option = 'distracted' THEN 1 END) AS relative_focused_rate,
       SUM(CASE WHEN tracking_option = 'brain_fog' THEN 1.0 END)/
       SUM(CASE WHEN tracking_category = 'mind' THEN 1 END) AS share_brain_fog,
       SUM(CASE WHEN tracking_option IN ('brain_fog', 'distracted', 'forgetful', 
                                         'stressed', 'unmotivated', 'unproductive') THEN 1.0 END)/
       SUM(CASE WHEN tracking_category = 'mind' THEN 1 END) AS share_negative_mind,
       SUM(CASE WHEN tracking_option NOT IN ('brain_fog', 'distracted', 'forgetful', 
                                         'stressed', 'unmotivated', 'unproductive') THEN 1.0 END)/
       SUM(CASE WHEN tracking_category = 'mind' THEN 1 END) AS share_positive_mind
FROM temp.mind_energy_cycle_tracking
WHERE did_track_mind AND tracking_category = 'mind' AND tracking_option != ''
GROUP BY 1
ORDER BY 1
;