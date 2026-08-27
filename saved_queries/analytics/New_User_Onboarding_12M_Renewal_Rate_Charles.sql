SELECT
    DATE_TRUNC('week', clue_users.backend_created_at) AS date,
    COUNT(*) AS count_users,
    AVG(CASE WHEN cumulative_subscription_duration > 12 THEN 1.0 ELSE 0 END) AS renewal_rate
FROM core.clue_users
INNER JOIN user_metrics.user_onboarding_funnel USING (analytics_id)
INNER JOIN der.subscription_history USING (analytics_id)
INNER JOIN core.countries ON subscription_history.country = countries.country_name
WHERE user_converted_with_this_subscription
    AND view_subscription_plans_navigation_context = 'onboarding'
    AND subscription_source = 'mobile'
    AND subscription_duration = 12
    AND clue_users.backend_created_at BETWEEN DATE '2025-04-14' AND DATE_ADD('day', -373, CURRENT_DATE)
    AND NOT started_in_intro_offer_period
    -- AND market IS NOT NULL
GROUP BY 1
ORDER BY 1, 2
;