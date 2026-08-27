SELECT major_app_version,
       market,
       COUNT(*) AS count_users,
       AVG(CASE WHEN DATE_DIFF('day', show_welcome_screen_ts, first_purchased_at) <= 14 THEN 1.0 ELSE 0 END) AS purchase_cvr
FROM user_metrics.user_onboarding_funnel
LEFT JOIN der.subscription_history ON user_onboarding_funnel.analytics_id = subscription_history.analytics_id
    AND user_converted_with_this_subscription
LEFT JOIN static.market_mapping ON user_onboarding_funnel.country_name = market_mapping.country
WHERE user_onboarding_funnel.platform = 'ios'
    AND show_welcome_screen_ts BETWEEN DATE '2025-01-01' AND DATE '2025-03-12'
    AND major_app_version >= 201
    AND market IS NOT NULL
    AND (user_onboarding_funnel.did_sign_in_ts IS NULL
             OR user_onboarding_funnel.did_sign_in_ts > user_onboarding_funnel.did_create_account_ts)
GROUP BY 1, 2
HAVING COUNT(*) > 5000
ORDER BY 1, 2
;