WITH pill_trackers AS
    (
        SELECT
            analytics_id,
            COUNT(DISTINCT date) AS count_total,
            COUNT(DISTINCT CASE WHEN type IN ('missing') THEN DATE END) AS count_missing,
            COUNT(DISTINCT CASE WHEN type IN ('late') THEN DATE END) AS count_missing,
            COUNT(DISTINCT CASE WHEN type IN ('taken') THEN DATE END) AS count_taken,
            COUNT(DISTINCT CASE WHEN type IN ('placebo') THEN DATE END) AS count_placebo,
            COUNT(DISTINCT CASE WHEN type IN ('taken') THEN FLOOR((day_of_year + 13) / 28) END) AS count_taken_cycles,
            COUNT(DISTINCT
                  CASE WHEN type IN ('placebo') THEN FLOOR((day_of_year + 13) / 28) END) AS count_placebo_cycles
        FROM
            der.backend_tracking
        INNER JOIN static.calendar USING (date)
            INNER JOIN der.users USING (analytics_id)
        WHERE
            category = 'birth_control_pill'
            AND DATE BETWEEN DATE (
            '2024-07-01')
            AND DATE (
            '2024-09-22')
            AND account_created_at
            < DATE (
            '2024-07-01')
            AND revision_type = 'measurements_tracked'
        GROUP BY
            1
    ), placebo_cycles AS (
SELECT analytics_id,
       FLOOR((day_of_year + 13) / 28) AS cycle_period,
       COUNT(*) AS count_tracking_points
FROM pill_trackers
INNER JOIN der.backend_tracking USING (analytics_id)
        INNER JOIN static.calendar USING (date)
WHERE count_taken_cycles = 3 AND count_placebo_cycles = 3
    AND category = 'birth_control_pill'
            AND DATE BETWEEN DATE (
            '2024-07-01')
            AND DATE (
            '2024-09-22')
            AND revision_type = 'measurements_tracked'
            AND type = 'placebo'
GROUP BY 1, 2
    )
SELECT count_tracking_points,
       COUNT(*) AS count_points,
       COUNT(*) * 1.0/(SELECT COUNT(*) FROM placebo_cycles) AS point_frequency
FROM placebo_cycles
GROUP BY 1
ORDER BY 1
;