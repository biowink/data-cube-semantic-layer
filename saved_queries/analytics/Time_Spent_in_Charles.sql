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
        first_seen::DATE BETWEEN '2023-03-02' AND '2023-03-06'
        AND first_platform = 'android'
        AND SPLIT_PART(first_app_version, '.', 1)::INT IN (73, 101)
        AND derived_tstamp BETWEEN '2023-02-28' AND '2023-03-13' AND
            mobile_event_name NOT IN('Did Get User Details','Tried To Get User Details','Show Reminder','Interact With Reminder','Notification State Changed','Reminder Shown Without Interaction','Magic Box Shown','Open Connections','Daily Backup Job','Daily Backup Job Scheduled','CBC Cycles Fetched','Sync Started','Sync Ended','CBC Availability Info','Screen Reader Status','Cbc Availability Info','Tried To Get Profile','Did Get Profile','Tried To Update Profile','Did Update Profile')

    GROUP BY 1, 2, 3
),
    last_events AS (
        SELECT
            first_major_app_version,
            first_seen,
            events.master_id,
            derived_tstamp,
            app_version,
            mobile_event_name,
            event_properties,
            ROW_NUMBER() OVER (PARTITION BY master_id ORDER BY derived_tstamp DESC) AS rnk
        FROM user_funnel
        INNER JOIN der.events
                USING (master_id)
        WHERE
            derived_tstamp >= '2023-03-02'
            AND derived_tstamp::DATE = first_seen::DATE
AND mobile_event_name NOT IN('Did Get User Details','Tried To Get User Details','Show Reminder','Interact With Reminder','Notification State Changed','Reminder Shown Without Interaction','Magic Box Shown','Open Connections','Daily Backup Job','Daily Backup Job Scheduled','CBC Cycles Fetched','Sync Started','Sync Ended','CBC Availability Info','Screen Reader Status','Cbc Availability Info','Tried To Get Profile','Did Get Profile','Tried To Update Profile','Did Update Profile')

    ),
    group_sizes AS (
        SELECT first_major_app_version, COUNT(*) AS total_users
        FROM last_events
        WHERE rnk = 1
        GROUP BY 1
    )
SELECT first_major_app_version,
       LEAST(DATEDIFF('second', first_seen, derived_tstamp)/60, 10) AS minutes_active,
       COUNT(*)::FLOAT/total_users AS share_users
FROM last_events
INNER JOIN group_sizes USING (first_major_app_version)
WHERE rnk = 1 AND DATEDIFF('second', first_seen, derived_tstamp) >= 0
GROUP BY 1, 2, total_users
ORDER BY 1, 2
;