WITH buy_screens AS (
    SELECT
        sp_users.master_id,
        last_platform,
        MAX(derived_tstamp) AS last_buy_screen_view
    FROM der.sp_users
    LEFT JOIN der.events
            ON sp_users.master_id = events.master_id AND mobile_event_name = 'View Subscription Plans'
    WHERE
        NOT last_is_subscribed
        AND last_seen >= CURRENT_DATE - 30
        AND first_seen < CURRENT_DATE - 30
    GROUP BY 1, 2
),
platform_agg AS (
SELECT last_platform, COUNT(*) AS total_users
FROM buy_screens
GROUP BY 1
)
SELECT FLOOR(DATEDIFF('day', last_buy_screen_view::DATE, CURRENT_DATE)/30) AS days_since_last_buy_screen,
        last_platform,
       COUNT(*)::FLOAT/total_users AS share_active_users
FROM buy_screens
LEFT JOIN platform_agg USING (last_platform)
GROUP BY 1, 2, total_users
ORDER BY 2, 1
;