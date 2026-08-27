WITH past_buy_screen_views AS (
SELECT DATE_TRUNC('month', first_purchased_at) AS month,
       analytics_id,
        SUM(count_view_subscription_plans) AS buy_screen_views
FROM der.subscription_history
INNER JOIN der.sessions USING (analytics_id)
WHERE user_converted_with_this_subscription
    AND first_purchased_at >= DATE '2021-01-01'
    AND first_purchased_at < DATE '2025-09-01'
    AND session_start >= DATE '2021-01-01'
    AND session_start < first_purchased_at
GROUP BY 1, 2
)
SELECT month,
    CASE
    WHEN buy_screen_views <= 1 THEN '1'
    WHEN buy_screen_views <= 10 THEN '2-10'
    WHEN buy_screen_views <= 50 THEN '11-50'
    WHEN buy_screen_views <= 100 THEN '50-100'
    WHEN buy_screen_views <= 200 THEN '101-200'
    WHEN buy_screen_views > 200 THEN '200+'
END as buy_screen_view_segment,
MIN(buy_screen_views) AS min_buy_screen_views,
    COUNT(*) AS count_converters
FROM past_buy_screen_views
WHERE buy_screen_views >= 0
GROUP BY 1, 2
ORDER BY 1, 3
;