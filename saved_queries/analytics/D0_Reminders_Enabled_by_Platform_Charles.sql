WITH  agg_reminders AS (
    SELECT
        new_users.analytics_id,
        platform,
        account_created_at,
        COUNT(DISTINCT CASE
                           WHEN enabled AND
                                DATEDIFF('day', new_users.account_created_at, backend_reminder_events.created_at) = 0
                               THEN reminder_type
                       END) AS count_d0_reminders_enabled,
        COUNT(DISTINCT CASE
                           WHEN enabled AND DATEDIFF('day', new_users.account_created_at,
                                                     backend_reminder_events.created_at) BETWEEN 0 AND 7
                               THEN reminder_type
                       END) AS count_d7_reminders_enabled
    FROM der.users new_users
    LEFT JOIN der.backend_reminder_events
            ON new_users.analytics_id = backend_reminder_events.analytics_id AND
               DATEDIFF('day', new_users.account_created_at, backend_reminder_events.created_at) BETWEEN 0 AND 7
    INNER JOIN user_metrics.user_first_session_attributes ON new_users.analytics_id = user_first_session_attributes.analytics_id
    WHERE account_created_at >= '2023-09-01'
    GROUP BY 1, 2, 3
)
SELECT platform,
       account_created_at::DATE,
       AVG(CASE WHEN count_d0_reminders_enabled > 0 THEN 1::FLOAT ELSE 0 END) AS share_d0_reminders_enabled
FROM agg_reminders
WHERE platform IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;