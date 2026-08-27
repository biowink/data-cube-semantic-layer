WITH user_segments AS (
SELECT
    account_created_at,
    analytics_id,
    MIN(CASE
        WHEN DATE_DIFF('day', account_created_at, backend_created_at) <= 7 AND partner = 'Lil-Lets' THEN 1
        WHEN DATE_DIFF('day', account_created_at, backend_created_at) <= 7 AND subscription_type = 'Subscription Purchased' THEN 2
        ELSE 3
        END
        ) AS user_segmentation
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
LEFT JOIN der.all_subscriptions_events USING (analytics_id)
WHERE
    account_created_at BETWEEN DATE '2025-08-01' AND DATE '2026-01-01'
    AND country_name = 'South Africa'
GROUP BY 1, 2
)
SELECT
    user_segmentation,
    month_index,
    COUNT(DISTINCT user_segments.analytics_id) AS cohort_size,
    COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT user_segments.analytics_id) AS retention_rate,
    COUNT(DISTINCT sessions.analytics_id || CAST(DATE(session_start) AS VARCHAR) ) * 1.0/(COUNT(DISTINCT sessions.analytics_id) * 30) AS dau_mau
FROM user_segments
CROSS JOIN (SELECT ROW_NUMBER() OVER (ORDER BY date ASC) - 1 AS month_index FROM static.calendar LIMIT 6) AS month_index
LEFT JOIN der.sessions ON user_segments.analytics_id = sessions.analytics_id
    AND sessions.session_start BETWEEN DATE '2025-08-01' AND DATE '2026-01-01'
    AND FLOOR(DATE_DIFF('day', account_created_at, session_start) * 1.0/30) = month_index
WHERE month_index < FLOOR(DATE_DIFF('day', account_created_at, CURRENT_DATE) * 1.0/30)
GROUP BY 1, 2
ORDER BY 1, 2
;