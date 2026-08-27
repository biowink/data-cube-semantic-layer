SELECT show_welcome_screen_ts::DATE AS date,
       COUNT(*) AS count,
       AVG(CASE WHEN view_subscription_plans_ts::DATE = show_welcome_screen_ts::DATE
                         AND view_subscription_plans_navigation_context = 'onboarding' THEN 1::FLOAT ELSE 0 END) AS share_onboarding_buy_screen,
       AVG(CASE WHEN subscription_started_ts::DATE = show_welcome_screen_ts::DATE
                         AND subscription_started_navigation_context = 'onboarding' THEN 1::FLOAT ELSE 0 END) AS onboarding_cvr
FROM user_metrics.user_onboarding_funnel
WHERE show_welcome_screen_ts >= '2023-09-01' AND platform = 'ios'
GROUP BY 1
ORDER BY 1 DESC. 
LIMIT 500
;