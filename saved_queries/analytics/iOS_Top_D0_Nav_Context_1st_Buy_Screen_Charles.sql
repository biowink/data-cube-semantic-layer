SELECT view_subscription_plans_navigation_context,
       COUNT(*),
       AVG(CASE WHEN subscription_started_ts::DATE = show_welcome_screen_ts::DATE THEN 1::FLOAT ELSE 0 END)
FROM user_metrics.user_onboarding_funnel
WHERE show_welcome_screen_ts >= CURRENT_DATE - 30 AND platform = 'ios' AND view_subscription_plans_ts::DATE = show_welcome_screen_ts::DATE
GROUP BY 1
ORDER BY 2 DESC
;