SELECT
    DATE_TRUNC('quarter', conversion_ts) AS quarter,
    APPROX_PERCENTILE(DATE_DIFF('month', account_created_at, conversion_ts), 0.5) AS median_time_unsubscribed
FROM user_metrics.user_subscription_status
INNER JOIN der.users USING (analytics_id)
WHERE conversion_ts BETWEEN DATE '2021-01-01' AND DATE '2026-01-01'
GROUP BY 1
ORDER BY 1
LIMIT 500
;