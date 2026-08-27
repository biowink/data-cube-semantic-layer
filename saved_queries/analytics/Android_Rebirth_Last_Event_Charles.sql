WITH user_funnel AS (
    SELECT
        master_id,
        SPLIT_PART(first_app_version, '.', 1)::INT AS first_major_app_version,
        first_seen,
        first_platform,
        derived_tstamp,
        mobile_event_name,
                FIRST_VALUE(mobile_event_name)
                OVER (PARTITION BY master_id, derived_tstamp::DATE ORDER BY derived_tstamp DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_mobile_event_name
    FROM der.sp_users
    LEFT JOIN der.events
            USING (master_id)
    LEFT JOIN der.subscription_history
            USING (master_id)
    WHERE
        first_seen::DATE BETWEEN '2023-03-02' AND '2023-03-06'
        AND ((SPLIT_PART(first_app_version, '.', 1)::INT IN (73, 101) AND first_platform = 'android') OR
             (SPLIT_PART(first_app_version, '.', 1)::INT > 100 AND first_platform = 'ios'))
        AND derived_tstamp BETWEEN '2023-03-02' AND '2023-03-07'
        AND mobile_event_name NOT IN
            ('Did Get User Details', 'Tried To Get User Details', 'Show Reminder', 'Interact With Reminder',
             'Notification State Changed', 'Reminder Shown Without Interaction', 'Magic Box Shown', 'Open Connections',
             'Daily Backup Job', 'Daily Backup Job Scheduled', 'CBC Cycles Fetched', 'Sync Started', 'Sync Ended',
             'CBC Availability Info', 'Screen Reader Status', 'Cbc Availability Info', 'Tried To Get Profile',
             'Did Get Profile', 'Tried To Update Profile', 'Did Update Profile', 'Session Started')
),
    segments AS (
        SELECT
            master_id,
            first_major_app_version > 100 AS is_rebirth,
            first_platform,
            MAX(CASE
                    WHEN DATEDIFF('day', first_seen, derived_tstamp) = 0 THEN last_mobile_event_name
                END) AS last_mobile_event_name,
            MAX(CASE WHEN DATEDIFF('day', first_seen, derived_tstamp) = 1 THEN 1 ELSE 0 END) AS is_d1_retained
        FROM user_funnel
        GROUP BY 1, 2, 3
    )
SELECT first_platform,
       is_rebirth,
       last_mobile_event_name,
       COUNT(*) AS count,
       COUNT(*)::FLOAT/total_users AS share,
       AVG(is_d1_retained::FLOAT) AS d1_retention_rate
FROM segments
LEFT JOIN (SELECT first_platform, is_rebirth, COUNT(*) AS total_users FROM segments GROUP BY 1, 2) AS agg_segments USING (first_platform, is_rebirth)
GROUP BY 1, 2, 3, total_users
ORDER BY 1, 2, 4 DESC
;