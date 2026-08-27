WITH pregnancies AS (
    SELECT
        master_id,
        date - previous_mode_tenure_days AS pregnancy_mode_start_dt
    FROM der.mode_switchers
    WHERE
        life_stage_previous_day = 'pregnant'
        AND subscription_status = 'subscribed_paid'
        AND date <= '2022-12-01'
        AND previous_mode_tenure_days > 90
),
    pregnancy_starts AS (
        SELECT
            master_id,
            pregnancy_mode_start_dt,
            MAX(cycle_end) AS last_cycle_dt
        FROM pregnancies
        INNER JOIN der.cycles
                USING (master_id)
        WHERE
            cycle_end < pregnancy_mode_start_dt
            AND cycle_completed
        GROUP BY 1, 2
    )
SELECT DATEDIFF('day', last_cycle_dt, date)/31 + 1 AS month,
       COUNT(*) AS pregnancy_count,
       AVG(CASE WHEN is_dau THEN 1::FLOAT ELSE 0 END) AS dau_rate,
       SUM(count_tracking_points - count_period_tracking_points)::FLOAT/SUM(CASE WHEN is_dau THEN 1 END) AS tracking_points_per_active_day,
       SUM(count_tracking_points - count_period_tracking_points)::FLOAT/SUM(1) * 31 AS tracking_points_per_month,
       AVG(CASE WHEN is_dau AND count_tracking_points - count_period_tracking_points > 0 THEN 1::FLOAT WHEN is_dau THEN 0 END) share_days_with_tracking,
       SUM(GREATEST(sum_session_length, 0))::FLOAT/SUM(CASE WHEN is_dau THEN 1 END) AS session_length_per_active_day
FROM pregnancy_starts
INNER JOIN der.clue_plus_user_lifetimes USING (master_id)
WHERE DATEDIFF('day', last_cycle_dt, date) BETWEEN 1 AND 330 AND life_stage = 'pregnant'
GROUP BY 1
HAVING month BETWEEN 2 AND 9
ORDER BY 1
;