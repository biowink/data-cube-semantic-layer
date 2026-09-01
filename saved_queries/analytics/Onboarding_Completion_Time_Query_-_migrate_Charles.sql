SELECT major_app_version,
       MIN(did_create_account_ts) AS release_ts,
       COUNT(*) AS count_users,
       APPROX_PERCENTILE(DATE_DIFF('millisecond', show_welcome_screen_ts, finish_onboarding_ts), 0.5)*1.0/1000 AS p50_onboarding_time,
       APPROX_PERCENTILE(DATE_DIFF('millisecond', show_welcome_screen_ts, finish_onboarding_ts), 0.75)*1.0/1000 AS p75_onboarding_time,
       APPROX_PERCENTILE(DATE_DIFF('millisecond', show_welcome_screen_ts, finish_onboarding_ts), 0.95)*1.0/1000 AS p95_onboarding_time
FROM user_metrics.user_onboarding_funnel
WHERE did_create_account_ts >= DATE '2024-01-01' and platform = 'ios' AND DATE_DIFF('day', show_welcome_screen_ts, finish_onboarding_ts) = 0
    AND select_onboarding_mode_mode = 'period tracking'
GROUP BY 1
HAVING COUNT(*) > 20000
ORDER BY 1
;