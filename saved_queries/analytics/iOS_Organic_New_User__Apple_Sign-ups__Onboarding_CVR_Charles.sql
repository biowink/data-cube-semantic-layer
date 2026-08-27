SELECT
    market,
    CASE WHEN user_onboarding_funnel.did_create_account_ts >= DATE '2025-04-02' THEN 'After Tariffs' ELSE 'Before Tariffs' END AS "user_onboarding_funnel.show_welcome_screen_date",
    COUNT(DISTINCT user_onboarding_funnel.sp_device_id ) AS "user_onboarding_funnel.user_count",
        CAST(COUNT(DISTINCT CASE WHEN ( CASE WHEN DATE_DIFF('day', DATE(user_onboarding_funnel.show_welcome_screen_ts), DATE(user_onboarding_funnel.subscription_started_ts)) <= 0
             THEN user_onboarding_funnel.subscription_started_ts END  ) IS NOT NULL AND  user_onboarding_funnel.subscription_started_navigation_context   = 'onboarding'
              THEN user_onboarding_funnel.sp_device_id
              ELSE NULL END ) AS DOUBLE) / COUNT(DISTINCT user_onboarding_funnel.sp_device_id ) AS "user_onboarding_funnel.share_started_subscription_onboarding"
FROM user_metrics.user_onboarding_funnel
INNER JOIN user_metrics.adjust_attribution USING (analytics_id)
INNER JOIN static.market_mapping on country_name = country
WHERE (user_onboarding_funnel.platform ) = 'ios' AND ((user_onboarding_funnel.app_version ) <> '206.0' OR (user_onboarding_funnel.app_version ) IS NULL) AND (CASE WHEN user_onboarding_funnel.major_app_version >= 100
              THEN user_onboarding_funnel.did_sign_in_ts IS NULL OR user_onboarding_funnel.did_sign_in_ts > user_onboarding_funnel.did_create_account_ts
              ELSE (CASE WHEN DATE_DIFF('day', DATE(user_onboarding_funnel.show_welcome_screen_ts), DATE(user_onboarding_funnel.open_cycle_view_ts)) <= 0
             THEN user_onboarding_funnel.open_cycle_view_ts END) IS NULL OR user_onboarding_funnel.view_subscription_plans_navigation_context = 'onboarding'
              END
              ) AND (user_onboarding_funnel.did_create_account_ts) >= (TIMESTAMP '2025-03-18')
                AND network = 'Organic' AND did_create_account_method = 'apple'
GROUP BY
    1,
    2
ORDER BY 1, 2