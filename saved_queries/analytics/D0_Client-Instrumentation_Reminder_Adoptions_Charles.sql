SELECT platform,
       did_create_account_ts::DATE AS date,
       AVG(CASE WHEN select_reminder_setup_response_onboarding_response = 'true'
                         AND select_reminder_setup_response_onboarding_ts::DATE = did_create_account_ts::DATE THEN 1::FLOAT ELSE 0 END) AS onboarding_rate,
       AVG(CASE WHEN select_reminder_prompt_response_response = 'true'
                         AND select_reminder_prompt_response_ts::DATE = did_create_account_ts::DATE THEN 1::FLOAT ELSE 0 END) AS prompt_rate,
       AVG(CASE WHEN (select_reminder_prompt_response_response = 'true'
                         AND select_reminder_prompt_response_ts::DATE = did_create_account_ts::DATE)
           OR (select_reminder_setup_response_onboarding_response = 'true'
                         AND select_reminder_setup_response_onboarding_ts::DATE = did_create_account_ts::DATE) THEN 1::FLOAT ELSE 0 END) AS combined_rate
FROM user_metrics.user_onboarding_funnel
WHERE analytics_id IS NOT NULL AND did_create_account_ts >= CURRENT_DATE - 30
GROUP BY 1, 2
ORDER BY 1, 2
;