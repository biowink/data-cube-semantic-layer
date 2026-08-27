WITH rebirth_switch AS (
    SELECT
        master_id,
        first_platform,
        MIN(session_start) AS rebirth_start
    FROM der.sp_users
    INNER JOIN der.sessions
            USING (master_id)
    WHERE
        first_seen <= '2022-07-01'
        AND SPLIT_PART(CASE WHEN last_app_version LIKE '%u%' THEN NULL ELSE last_app_version END, '.', 1)::INT > 100
        AND major_app_version > 100
        AND session_start >= '2022-11-01'
    GROUP BY 1, 2
), retention as (
    SELECT
        master_id,
        first_platform,
        COUNT(DISTINCT CASE
                           WHEN derived_tstamp::DATE < rebirth_start::DATE AND mobile_event_name LIKE '%Reminder%'
                               THEN derived_tstamp::DATE
                       END) AS count_legacy_reminders,

        COUNT(DISTINCT CASE
                           WHEN derived_tstamp::DATE < rebirth_start::DATE AND
                                mobile_event_name IN ('Open Cycle View', 'Open Data Entry') THEN derived_tstamp::DATE
                       END) AS count_legacy_active_days,
        COUNT(DISTINCT CASE
                           WHEN derived_tstamp::DATE > rebirth_start::DATE AND
                                mobile_event_name IN ('Open Cycle View', 'Open Data Entry') THEN derived_tstamp::DATE
                       END) AS count_rebirth_active_days
    FROM rebirth_switch
    INNER JOIN der.events
            USING (master_id)
    WHERE
        DATEDIFF('day', derived_tstamp, rebirth_start) BETWEEN -30 AND 30
        AND rebirth_start::DATE <= CURRENT_DATE - 30
        AND mobile_event_name IN ('Show Reminder',
                                  'Open Reminders',
                                  'Interact With Reminder',
                                  'Delayed Interact With Reminder',
                                  'Reminder Shown Without Interaction',
                                  'Open Cycle View', 'Open Data Entry')
    GROUP BY 1, 2
)
SELECT first_platform,
       count_legacy_reminders > 0 AS had_reminders,
       count_legacy_active_days,
       COUNT(*) AS count_users,
       AVG(count_rebirth_active_days::FLOAT) AS post_rebirth_dau_mau
FROM retention
WHERE first_platform = 'android'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;