    WITH event_curation_and_indexing AS (
        -- This CTE pulls the events related to onboarding for users within the first 30 days of `first_seen` and
        -- then indexes them so that the first event and last event of each event type can be retrieved
        SELECT
            master_id,
            first_seen,
            sp_device_id,
            derived_tstamp,
            mobile_event_name,
            event_properties,
            platform,
            country_name AS country,
            app_version,
            session_index,
            major_app_version,
            ROW_NUMBER()
            OVER (PARTITION BY master_id, mobile_event_name ORDER BY derived_tstamp) AS user_event_index,
            ROW_NUMBER()
            OVER (PARTITION BY master_id, mobile_event_name ORDER BY derived_tstamp DESC) AS user_event_reverse_index
        FROM der.events
        INNER JOIN der.sp_users
                USING (master_id)
        WHERE
                mobile_event_name IN ('Show Welcome Screen',
                                      'Select Onboarding Mode',
                                      'Subscription Started'
                )
            AND first_seen BETWEEN '2022-10-01' AND CURRENT_DATE - 30
            AND DATEDIFF('day', first_seen, derived_tstamp::DATE) BETWEEN 0 AND 30
            AND is_valid_json(event_properties)
            AND derived_tstamp >= '2022-10-01' 
            AND first_platform = 'ios'
    ), user_onboarding_agg AS (
    SELECT event_curation_and_indexing.master_id,
           first_seen AS first_seen_ts,
           MIN(CASE WHEN mobile_event_name = 'Select Onboarding Mode' AND user_event_index = 1
               THEN derived_tstamp END) AS first_select_onboarding_mode_ts,
           MIN(CASE WHEN mobile_event_name = 'Select Onboarding Mode' AND user_event_index = 1
                AND major_app_version < 100
               THEN JSON_EXTRACT_PATH_TEXT(event_properties, 'Mode')
               WHEN mobile_event_name = 'Select Onboarding Mode' AND user_event_index = 1
                AND major_app_version >= 100
               THEN JSON_EXTRACT_PATH_TEXT(event_properties, 'Intended Mode') END) AS first_select_onboarding_mode_mode,
           MIN(CASE WHEN mobile_event_name = 'Subscription Started' AND user_event_index = 1
               THEN derived_tstamp END) AS subscription_started_ts,
           MIN(CASE WHEN mobile_event_name = 'Subscription Started' AND user_event_index = 1
               THEN JSON_EXTRACT_PATH_TEXT(event_properties, 'Navigation Context') END) AS subscription_started_navigation_context,
           MIN(CASE WHEN mobile_event_name = 'Subscription Started' AND user_event_index = 1
               THEN session_index END) AS subscription_started_session_index,
           MIN(CASE WHEN mobile_event_name = 'Subscription Started' AND user_event_index = 1
               THEN JSON_EXTRACT_PATH_TEXT(event_properties, 'Product Id') END) AS subscription_started_product_id,
           MIN(first_purchased_at) AS subscription_purchased_ts,
           MIN(CASE WHEN mobile_event_name = 'Open Cycle View' AND user_event_index = 1
               THEN derived_tstamp END) AS open_cycle_view_ts
    FROM event_curation_and_indexing
    LEFT JOIN der.subscription_history ON event_curation_and_indexing.master_id = subscription_history.master_id
            AND event_curation_and_indexing.mobile_event_name = 'Subscription Started'
            AND JSON_EXTRACT_PATH_TEXT(event_properties, 'Product Id') = subscription_history.product_id
            AND DATEDIFF('day', derived_tstamp::DATE, started_at::DATE) >= 0
    GROUP BY 1, 2
)
    SELECT first_select_onboarding_mode_mode LIKE '%conceive%' AS conceive_onboarding,
       DATE_TRUNC('week', first_seen_ts) AS week,
       COUNT(DISTINCT user_onboarding_agg.master_id) AS count_users,
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', first_seen_ts, session_start) = 1 THEN sessions.master_id END) AS count_d1_retained,
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', first_seen_ts, session_start) BETWEEN 1 AND 7 THEN sessions.master_id END) AS count_w1_retained,
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', first_seen_ts, session_start) BETWEEN 31 AND 60 THEN sessions.master_id END) AS count_m1_retained,
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', first_seen_ts, subscription_started_ts) BETWEEN 1 AND 30 THEN sessions.master_id END) AS count_late_converted,
       count_d1_retained::FLOAT/NULLIF(count_users, 0) AS d1_retention_rate,
       count_w1_retained::FLOAT/NULLIF(count_users, 0) AS w1_retention_rate,
       count_m1_retained::FLOAT/NULLIF(count_users, 0) AS m1_retention_rate,
       count_late_converted::FLOAT/NULLIF(count_users, 0) AS late_conversion_rate
FROM user_onboarding_agg
LEFT JOIN der.sessions
    ON user_onboarding_agg.master_id = sessions.master_id AND DATEDIFF('day', first_seen_ts, session_start) BETWEEN 0 AND 60
WHERE first_select_onboarding_mode_mode IN ('clue conceive', 'conceive', 'period tracking')
  AND (subscription_started_ts::DATE > first_seen_ts::DATE OR subscription_started_ts IS NULL)
GROUP BY 1, 2
ORDER BY 1, 2
;