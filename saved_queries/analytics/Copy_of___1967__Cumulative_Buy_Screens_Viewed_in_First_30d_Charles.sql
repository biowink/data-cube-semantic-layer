WITH integer_offsets AS (
    SELECT ROW_NUMBER() OVER (ORDER BY date) - 1 AS date_offset
    FROM static.calendar
    LIMIT 31
),
    buy_screens AS (
    SELECT
        sp_users.master_id,
        first_platform,
        date_offset,
        COUNT(root_id) AS buy_screen_views
    FROM der.sp_users
    CROSS JOIN integer_offsets
    LEFT JOIN der.events
            ON sp_users.master_id = events.master_id AND mobile_event_name IN ('View Subscription Plans')
                AND DATEDIFF('day', first_seen::DATE, derived_tstamp::DATE) = date_offset
    WHERE
        NOT last_is_subscribed
        AND first_seen BETWEEN '2023-01-01' AND CURRENT_DATE - 1
        AND DATEDIFF('day', first_seen::DATE, CURRENT_DATE) > date_offset
    GROUP BY 1, 2, 3
),
    running_sums AS (
        SELECT master_id,
               first_platform,
               date_offset,
               SUM(buy_screen_views) OVER (PARTITION BY master_id ORDER BY date_offset ASC
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_buy_screen_views
        FROM buy_screens
    )
SELECT first_platform,
       date_offset,
       COUNT(*) AS count_users,
       AVG(running_buy_screen_views::FLOAT) AS avg_running_buy_screen_views
FROM running_sums
GROUP BY 1, 2
ORDER BY 1, 2
;