SELECT DATE(did_create_account_ts) AS date,
    COUNT(*) AS user_count,
    AVG(CASE WHEN DATE_DIFF('hour', did_create_account_ts, subscription_started_ts) = 0
        AND subscription_started_navigation_context = 'onboarding' THEN 1.0 ELSE 0 END) AS onboarding_cvr
FROM user_metrics.user_onboarding_funnel
LEFT JOIN user_metrics.adjust_attribution USING (analytics_id)
WHERE platform = 'ios'
    AND did_create_account_ts >= DATE '2025-03-01'
    AND network = 'Organic'
GROUP BY 1
ORDER BY 1
;