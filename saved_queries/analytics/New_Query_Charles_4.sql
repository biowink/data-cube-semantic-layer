SELECT
    major_app_version,
    platform,
    COUNT(*) AS count_users,
    AVG(CASE WHEN view_subscription_plans_onboarding_ts IS NULL THEN 1.0 ELSE 0 END) AS share_skipping_onboarding
FROM user_metrics.user_onboarding_funnel
WHERE
    did_create_account_ts >= DATE '2026-04-01'
    AND DATE_DIFF('day', did_create_account_ts, show_marketing_source_screen_ts) = 0
    AND platform IS NOT NULL
GROUP BY 1, 2
HAVING COUNT(*) > 2700
ORDER BY 1, 2
;