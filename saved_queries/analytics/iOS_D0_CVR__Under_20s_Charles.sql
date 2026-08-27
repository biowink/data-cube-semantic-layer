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
            derived_tstamp >= '2023-04-10'
            AND major_app_version > 100
            AND mobile_event_name = 'Select Birthdate'
    )
    WHERE rnk = 1
)
SELECT user_first_session_attributes.major_app_version,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       COUNT(DISTINCT CASE WHEN subscriptions_events.backend_created_at::DATE = account_created_at::DATE 
           THEN users.analytics_id END) AS count_d0_converters,
    count_d0_converters::FLOAT/count_users AS d0_cvr

FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
INNER JOIN user_metrics.user_onboarding_funnel USING (analytics_id)
INNER JOIN first_info USING (sp_device_id)
LEFT JOIN der.subscriptions_events USING (analytics_id)
LEFT JOIN der.backend_gympass_users USING (analytics_id)
WHERE backend_gympass_users.analytics_id IS NULL AND account_created_at >= '2023-04-10'
  AND user_first_session_attributes.platform = 'ios' 
  AND DATEDIFF('month', birth_date, CURRENT_DATE) < 20*12
GROUP BY 1
HAVING count_users > 1000
ORDER BY 1 DESC
;