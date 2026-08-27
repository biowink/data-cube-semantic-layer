WITH starting_cohort AS (
SELECT
    DISTINCT analytics_id
FROM der.sessions
INNER JOIN der.backend_reminders USING (analytics_id)
WHERE session_start BETWEEN CURRENT_DATE - INTERVAL '61' DAY AND CURRENT_DATE - INTERVAL '31' DAY
AND enabled
)
SELECT COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT starting_cohort.analytics_id) AS mom_retention
FROM starting_cohort
LEFT JOIN der.sessions ON starting_cohort.analytics_id = sessions.analytics_id
                              AND session_start BETWEEN CURRENT_DATE - INTERVAL '31' DAY AND CURRENT_DATE - INTERVAL '1' DAY