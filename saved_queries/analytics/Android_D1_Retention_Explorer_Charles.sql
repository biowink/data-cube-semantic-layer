SELECT user_onboarding_funnel.major_app_version,
       select_onboarding_mode_mode,
       COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT user_onboarding_funnel.analytics_id) AS d1_retention
FROM user_metrics.user_onboarding_funnel
LEFT JOIN der.sessions ON user_onboarding_funnel.analytics_id = sessions.analytics_id
    AND DATE_DIFF('day', did_create_account_ts, session_start) = 1
    AND sessions.session_start >= DATE '2025-01-01'
WHERE did_create_account_ts >= DATE '2025-01-01'
    AND did_create_account_ts < DATE '2025-03-31'
    AND user_onboarding_funnel.platform = 'android'
    AND user_onboarding_funnel.major_app_version BETWEEN 185 AND 196
    AND user_onboarding_funnel.app_version NOT IN ('196.1', '196.0', '195.0')
    AND select_onboarding_mode_mode IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;