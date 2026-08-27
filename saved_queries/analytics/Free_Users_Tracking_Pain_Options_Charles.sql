SELECT
    type,
    CAST(ROUND(COUNT(DISTINCT analytics_id) * 1.5) AS INT)/1000*1000 AS count_users
FROM der.backend_tracking
LEFT JOIN user_metrics.user_subscription_status USING (analytics_id)
WHERE
    category = 'pain'
    AND backend_updated_at >= CURRENT_DATE - INTERVAL '30' DAY
    AND NOT COALESCE(is_clue_plus, FALSE)
GROUP BY 1
ORDER BY 2 DESC
;