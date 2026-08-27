SELECT
    (DATE_FORMAT(DATE_TRUNC('DAY', DATE_ADD('day', (0 - MOD((DAY_OF_WEEK("sessions"."session_start") % 7) - 1 + 7, 7)), "sessions"."session_start")), '%Y-%m-%d')) AS "sessions.start_week",
    CASE WHEN is_clue_plus THEN last_product_id END as product_id,
    COUNT(DISTINCT sessions.analytics_id ) AS "sessions.user_count"
FROM
    "der"."sessions" AS "sessions"
    LEFT JOIN "core"."clue_users" AS "users" ON "sessions"."analytics_id" = "users"."analytics_id"
    LEFT JOIN user_metrics.user_subscription_status ON (user_subscription_status.analytics_id = users.analytics_id)
WHERE ((( "sessions"."session_start" ) >= ((DATE_ADD('week', -12, DATE_TRUNC('DAY', DATE_ADD('day', (0 - MOD((DAY_OF_WEEK(CAST(CAST(DATE_TRUNC('DAY', NOW()) AS DATE) AS TIMESTAMP)) % 7) - 1 + 7, 7)), CAST(CAST(DATE_TRUNC('DAY', NOW()) AS DATE) AS TIMESTAMP))))))
            AND ( "sessions"."session_start" ) < ((DATE_ADD('week', 12, DATE_ADD('week', -12, DATE_TRUNC('DAY', DATE_ADD('day', (0 - MOD((DAY_OF_WEEK(CAST(CAST(DATE_TRUNC('DAY', NOW()) AS DATE) AS TIMESTAMP)) % 7) - 1 + 7, 7)), CAST(CAST(DATE_TRUNC('DAY', NOW()) AS DATE) AS TIMESTAMP)))))))))
  AND "sessions"."platform" = 'ios'
  AND (date_diff('day', CAST((DATE_FORMAT(users.backend_created_at , '%Y-%m-%d'))  AS TIMESTAMP), CAST((DATE_FORMAT(sessions.session_start , '%Y-%m-%d'))  AS TIMESTAMP))) >= 31
group by 1, 2 order by 1, 2