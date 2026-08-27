WITH retention_array AS (
    SELECT ROW_NUMBER() OVER (ORDER BY date) AS retention_date
    FROM static.calendar
)
SELECT first_select_onboarding_mode_mode,
       NVL(DATEDIFF('minute', first_select_onboarding_mode_ts, subscription_started_ts) <= 30, FALSE) AS subscribed_right_away,
       retention_date,
       COUNT(DISTINCT user_onboarding_funnel.master_id) AS cohort_user_count,
       COUNT(DISTINCT sp_sessions.master_id) AS active_user_count,
       active_user_count::FLOAT/cohort_user_count AS activity_retention
FROM der.user_onboarding_funnel
CROSS JOIN retention_array
LEFT JOIN der.sp_sessions ON user_onboarding_funnel.master_id = sp_sessions.master_id
                                 AND DATEDIFF('day', first_select_onboarding_mode_ts, start) = retention_date
WHERE first_select_onboarding_mode_ts BETWEEN '2022-10-01' AND CURRENT_DATE - 7 
AND subscribed_right_away 
AND first_select_onboarding_mode_mode != 'clue connect'
AND retention_date BETWEEN 1 AND 30
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;