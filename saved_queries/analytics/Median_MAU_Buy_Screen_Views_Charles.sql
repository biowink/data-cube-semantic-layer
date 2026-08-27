WITH session_data AS (
SELECT analytics_id,
       DATE_TRUNC('month', session_start) AS month,
       SUM(CASE WHEN product_tier = 'clue plus' THEN 1 ELSE 0 END) > 0 AS has_clue_plus,
       SUM(count_view_subscription_plans) AS buy_screen_views
FROM der.sessions
INNER JOIN der.users USING (analytics_id)
WHERE session_start BETWEEN DATE '2021-01-01' AND DATE '2025-09-01'
    AND DATE_DIFF('month', DATE_TRUNC('month', account_created_at), DATE_TRUNC('month', session_start)) > 0
GROUP BY 1, 2
)
SELECT month,
    AVG(buy_screen_views * 1.0) AS avg_buy_screen_views,
    APPROX_PERCENTILE(buy_screen_views * 1.0, 0.5) AS median_buy_screen_views,
    AVG(CASE WHEN buy_screen_views = 0 THEN 1.0 ELSE 0 END) AS share_zero_buy_screens
FROM session_data
WHERE NOT has_clue_plus
GROUP BY 1
ORDER BY 1
;