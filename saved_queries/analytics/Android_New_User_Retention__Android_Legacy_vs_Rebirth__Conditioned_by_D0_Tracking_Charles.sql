WITH user_funnel AS (
    SELECT
        master_id,
        SPLIT_PART(first_app_version, '.', 1)::INT AS first_major_app_version,
        first_seen,
        MIN(CASE
                WHEN DATEDIFF('day', first_seen, derived_tstamp) = 0 AND mobile_event_name = 'Show Welcome Screen'
                    THEN derived_tstamp
            END) AS min_welcome_screen_ts,
        MIN(CASE
                WHEN DATEDIFF('day', first_seen, derived_tstamp) = 0 AND mobile_event_name = 'Did Create Account'
                    THEN derived_tstamp
            END) AS min_did_create_account,
        MIN(CASE
                WHEN DATEDIFF('day', first_seen, derived_tstamp) = 0 AND mobile_event_name = 'Subscription Started'
                    THEN derived_tstamp
            END) AS min_subscription_started,
        MAX(CASE
                WHEN mobile_event_name = 'Exit Data Entry' AND DATEDIFF('day', first_seen, derived_tstamp) = 0 AND
                     JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') != ''
                    THEN derived_tstamp
            END) AS exit_data_entry_ts,
        
        SUM(NVL(CASE
                WHEN mobile_event_name = 'Exit Data Entry' AND DATEDIFF('day', first_seen, derived_tstamp) = 0 AND
                     CASE WHEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') != ''
                     THEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points')::INT END > 0
                    THEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points')::INT
            END, 0)) AS d0_data_points_tracked,
        MIN(CASE WHEN DATEDIFF('day', first_seen, derived_tstamp) = 1 THEN derived_tstamp END) AS min_d1_activity,
        MIN(CASE WHEN DATEDIFF('day', first_seen, derived_tstamp) = 2 THEN derived_tstamp END) AS min_d2_activity,
        MIN(CASE WHEN DATEDIFF('day', first_seen, derived_tstamp) BETWEEN 1 AND 7 THEN derived_tstamp END) AS min_w1_activity,
        MIN(first_purchased_at) AS first_purchased_at
    FROM der.sp_users
    LEFT JOIN der.events
            USING (master_id)
    LEFT JOIN der.subscription_history
            USING (master_id)
    WHERE
        first_seen BETWEEN '2023-03-01 11:00:00' AND '2023-03-07 09:00:00'
        AND first_platform = 'android'
        AND SPLIT_PART(first_app_version, '.', 1)::INT IN (73, 101)
        AND derived_tstamp BETWEEN '2023-02-28' AND '2023-03-13'
        AND mobile_event_name NOT IN('Did Get User Details','Tried To Get User Details','Show Reminder','Interact With Reminder','Notification State Changed','Reminder Shown Without Interaction','Magic Box Shown','Open Connections','Daily Backup Job','Daily Backup Job Scheduled','CBC Cycles Fetched','Sync Started','Sync Ended','CBC Availability Info','Screen Reader Status','Cbc Availability Info','Tried To Get Profile','Did Get Profile','Tried To Update Profile','Did Update Profile')

    GROUP BY 1, 2, 3
)
SELECT first_major_app_version,
       LEAST(d0_data_points_tracked, 20) AS d0_data_points_tracked,
       COUNT(first_seen) AS count_new_users,
       COUNT(CASE WHEN DATEDIFF('day', first_seen, first_purchased_at::DATE) <= 7
           THEN master_id END) AS count_d7_purchase_conversion,
        COUNT(CASE WHEN min_did_create_account IS NOT NULL AND min_d1_activity IS NOT NULL THEN master_id END) AS count_d1_activity_retained,
        COUNT(CASE WHEN min_did_create_account IS NOT NULL AND min_d1_activity IS NOT NULL AND min_d2_activity IS NOT NULL
            THEN master_id END) AS count_d12_activity_retained,
        COUNT(CASE WHEN min_did_create_account IS NOT NULL AND min_w1_activity IS NOT NULL THEN master_id END) AS count_w1_activity_retained,
        count_d1_activity_retained::FLOAT/count_new_users AS d1_retention_rate,
        count_d12_activity_retained::FLOAT/count_new_users AS d12_retention_rate,
        count_w1_activity_retained::FLOAT/count_new_users AS w1_retention_rate
FROM user_funnel
WHERE min_did_create_account IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;