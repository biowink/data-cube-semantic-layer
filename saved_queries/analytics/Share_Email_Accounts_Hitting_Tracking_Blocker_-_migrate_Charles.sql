SELECT DATE_TRUNC('month', did_create_account_ts) AS month,
AVG(CASE WHEN show_tracking_block_modal_ts IS NOT NULL THEN 1.0 ELSE 0 END) AS share_email_users_blocked
FROM user_metrics.user_onboarding_funnel
WHERE did_create_account_method = 'email'
 AND did_create_account_ts BETWEEN DATE '2024-01-01' AND CURRENT_DATE - INTERVAL '30' DAY
GROUP BY 1
ORDER BY 1
;