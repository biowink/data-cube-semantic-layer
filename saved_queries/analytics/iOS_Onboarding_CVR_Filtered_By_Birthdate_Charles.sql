WITH first_info AS (
    SELECT *
    FROM (
        SELECT
            sp_device_id,
            (case when left(NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'Birthdate'), ''), 10) ~ '^(19|20)[0-9][0-9]-[0-1][0-9]-[0-3][0-9]$'
      then to_date(left(NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'Birthdate'), ''), 10), 'YYYY-MM-DD') END) AS birth_date,
            ROW_NUMBER() OVER (PARTITION BY sp_device_id ORDER BY derived_tstamp) AS rnk
        FROM der.events
        WHERE
            derived_tstamp >= '2023-08-01'
            AND major_app_version > 100
            AND mobile_event_name = 'Select Birthdate'
    )
    WHERE rnk = 1
)
SELECT DATE_TRUNC('week', show_welcome_screen_ts::DATE) AS date,
       COUNT(*) AS count,
       AVG(CASE WHEN view_subscription_plans_ts::DATE = show_welcome_screen_ts::DATE
                         AND view_subscription_plans_navigation_context = 'onboarding' THEN 1::FLOAT ELSE 0 END) AS share_onboarding_buy_screen,
       AVG(CASE WHEN subscription_started_ts::DATE = show_welcome_screen_ts::DATE
                         AND subscription_started_navigation_context = 'onboarding' THEN 1::FLOAT ELSE 0 END) AS onboarding_cvr
FROM user_metrics.user_onboarding_funnel
INNER JOIN first_info USING (sp_device_id)
WHERE show_welcome_screen_ts >= '2023-08-01' AND platform = 'ios' AND DATEDIFF('month', birth_date, CURRENT_DATE) > 20*12
GROUP BY 1
ORDER BY 1 DESC
LIMIT 500