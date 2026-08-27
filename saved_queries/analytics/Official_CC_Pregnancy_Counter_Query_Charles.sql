SELECT COUNT(*)
FROM (SELECT
    analytics_id,
    MIN(CASE WHEN (mode = 'conceive' AND had_positive_pregnancy_test) OR (mode = 'pregnancy' AND mode_previous_day = 'conceive') THEN date END) AS pregnancy_date,
    first_conceive_mode_dt
FROM
    der.clue_plus_user_lifetimes
INNER JOIN (SELECT analytics_id, MIN(date) AS first_conceive_mode_dt FROM der.clue_plus_user_lifetimes WHERE mode = 'conceive' GROUP BY 1) firstcc USING (analytics_id)
WHERE 
    (CASE WHEN (mode = 'conceive' AND had_positive_pregnancy_test) OR (mode = 'pregnancy' AND mode_previous_day = 'conceive') THEN date END) > DATEADD(day, 5, first_conceive_mode_dt)
GROUP BY
    analytics_id, first_conceive_mode_dt);