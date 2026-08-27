SELECT ROUND((date::DATE - cycle_start::DATE)::FLOAT/(cycle_end::DATE - cycle_start::DATE) * 28) AS normalized_time_into_cycle,
       COUNT(*) AS cycle_count,
       AVG(CASE WHEN is_dau THEN 1::FLOAT ELSE 0 END) AS dau_rate,
       AVG(CASE WHEN is_dau AND count_tracking_points > 0 THEN 1::FLOAT WHEN is_dau THEN 0 END) share_days_with_tracking,
       SUM(count_period_tracking_points)::FLOAT/SUM(CASE WHEN is_dau THEN 1 END) AS period_tracking_points_per_active_day,
       SUM(count_tracking_points - count_period_tracking_points)::FLOAT/SUM(CASE WHEN is_dau THEN 1 END) AS other_tracking_points_per_active_day,
       AVG(count_period_tracking_points::FLOAT) AS period_tracking_points_per_day,
       AVG(count_tracking_points - count_period_tracking_points::FLOAT) AS other_tracking_points_per_day,
       SUM(GREATEST(sum_session_length, 0))::FLOAT/SUM(CASE WHEN is_dau THEN 1 END) AS session_length_per_active_day
FROM der.cycles
INNER JOIN der.clue_plus_user_lifetimes USING (master_id)
WHERE cycle_completed AND cycle_is_valid AND NOT cycle_excluded
  AND date BETWEEN cycle_start::DATE AND cycle_end::DATE
  AND cycle_end::DATE - cycle_start::DATE BETWEEN 20 AND 40
  AND life_stage = 'menstruating'
  AND subscription_status = 'subscribed_paid'
GROUP BY 1
ORDER BY 1
;