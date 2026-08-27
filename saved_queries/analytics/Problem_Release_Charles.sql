SELECT
    DATE(show_welcome_screen_ts) AS date,
    major_app_version >= 257 AS late_release,
    COUNT(*) AS count_users,
    AVG(CASE WHEN view_subscription_plans_onboarding_ts IS NULL THEN 1.0 ELSE 0 END) AS share_skipping_onboarding
FROM user_metrics.user_onboarding_funnel
WHERE
    did_create_account_ts >= DATE '2026-05-01'
    AND DATE_DIFF('hour', show_welcome_screen_ts, show_marketing_source_screen_ts) <= 1
    AND user_onboarding_funnel.platform = 'android'
GROUP BY 1, 2
ORDER BY 1, 2
;