WITH pregnancy_test_users AS (
SELECT
    analytics_id,
    MIN(date) AS pregnancy_test_dt
FROM research.backend_measurements
WHERE
    date BETWEEN DATE '2025-05-01' AND DATE '2025-05-31'
    AND category = 'tests'
    AND value_data = 'pregnancy_positive'
GROUP BY 1
),
    pregnancy_mode_users AS (
SELECT
    analytics_id,
    MIN(date) AS pregnancy_mode_dt
FROM der.clue_plus_user_lifetimes
WHERE
    mode_previous_day != 'pregnancy'
    AND mode = 'pregnancy'
    AND date BETWEEN DATE '2025-05-01' AND DATE '2025-05-31'
GROUP BY 1
),
    existing_users AS (
SELECT
    analytics_id,
    platform,
    COUNT(*) AS count_sessions,
    SUM(CASE WHEN product_tier = 'clue plus' THEN 1 ELSE 0 END) > 0 AS is_clue_plus
FROM der.sessions
INNER JOIN core.clue_users USING (analytics_id)
WHERE
    platform IS NOT NULL
    AND DATE_DIFF('month', clue_users.backend_created_at, session_start) >= 12
    AND session_start BETWEEN DATE '2025-05-01' AND DATE '2025-06-01'
GROUP BY 1, 2
),
    user_segments AS (
SELECT
    analytics_id,
    platform,
    CASE
        WHEN pregnancy_mode_dt IS NOT NULL THEN 'pregnancy mode'
        WHEN pregnancy_test_dt IS NOT NULL THEN 'test only'
        ELSE 'neither'
    END AS preg_segment
FROM existing_users
LEFT JOIN pregnancy_test_users USING (analytics_id)
LEFT JOIN pregnancy_mode_users USING (analytics_id)
WHERE NOT is_clue_plus
),
    user_segment_totals AS (
SELECT
    preg_segment,
    COUNT(*) AS total_user_count
FROM user_segments
GROUP BY 1
)
SELECT
    DATE_TRUNC('month', session_start) AS month,
    user_segments.preg_segment,
    total_user_count,
    COUNT(DISTINCT analytics_id)*1.0/total_user_count AS monthly_retention_rate
FROM user_segments
INNER JOIN der.sessions USING (analytics_id)
INNER JOIN user_segment_totals
    ON user_segments.preg_segment = user_segment_totals.preg_segment
WHERE
    session_start BETWEEN DATE '2025-05-01' AND DATE '2026-06-01'
GROUP BY 1, 2, total_user_count
ORDER BY 1, 2
;