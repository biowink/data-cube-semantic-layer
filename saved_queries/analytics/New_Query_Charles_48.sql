SELECT major_app_version,
       COUNT(*) AS count,
       AVG(CASE WHEN DATEDIFF('day', show_welcome_screen_ts, show_user_intent_screen_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS saw_intent_screen,
       AVG(CASE WHEN DATEDIFF('day', show_welcome_screen_ts, did_create_account_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS did_create_account,
       AVG(CASE WHEN DATEDIFF('day', show_welcome_screen_ts, finish_onboarding_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS finished_onboarding,
       AVG(CASE WHEN DATEDIFF('day', show_welcome_screen_ts, open_data_entry_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS opened_data_entry,
       AVG(CASE WHEN DATEDIFF('day', show_welcome_screen_ts, exit_data_entry_saving_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS exited_data_entry_saving,
       AVG(CASE WHEN DATEDIFF('day', show_welcome_screen_ts, view_subscription_plans_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS viewed_subscription_plans,
       AVG(CASE WHEN DATEDIFF('day', show_welcome_screen_ts, subscription_started_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS started_subscription
FROM user_metrics.user_onboarding_funnel
WHERE show_welcome_screen_ts BETWEEN CURRENT_DATE - 60 AND CURRENT_DATE - 1 AND platform = 'android'
-- AND major_app_version IN (119, 120, 122, 123)
  AND DATEDIFF('day', show_welcome_screen_ts, did_create_account_ts) = 0
-- AND did_create_account_ts IS NULL
GROUP BY 1
HAVING count > 10000
ORDER BY 1
;