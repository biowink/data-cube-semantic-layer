WITH new_users AS (
    SELECT
        users.analytics_id,
        sp_users.first_platform,
        users.backend_created_at,
        MIN(CASE WHEN mobile_event_name = 'Did Create Account' THEN derived_tstamp END) AS did_create_account_ts,
        MIN(CASE
                WHEN mobile_event_name = 'Did Create Account' AND JSON_EXTRACT_PATH_TEXT(event_properties, 'Method') ||
                                                                  JSON_EXTRACT_PATH_TEXT(event_properties, 'Authentication Method') =
                                                                  'email' THEN derived_tstamp
            END) AS did_create_email_account_ts,
        MIN(CASE WHEN mobile_event_name = 'Email Verified' THEN derived_tstamp END) AS email_verified_ts
    FROM import.users
    LEFT JOIN der.sp_users
            USING (analytics_id)
    LEFT JOIN der.events
            ON users.analytics_id = events.analytics_id AND
               mobile_event_name IN ('Did Create Account', 'Email Verified') AND events.derived_tstamp >= '2023-01-01'
    WHERE
        users.backend_created_at >= '2023-02-01'
    GROUP BY 1, 2, 3
)
SELECT first_platform,
       backend_created_at::DATE,
       COUNT(*),
       AVG(CASE WHEN did_create_account_ts IS NOT NULL THEN 1::FLOAT ELSE 0 END) AS share_create_account,
       AVG(CASE WHEN did_create_email_account_ts IS NOT NULL THEN 1::FLOAT ELSE 0 END) AS share_create_email_account,
       AVG(CASE WHEN email_verified_ts IS NOT NULL THEN 1::FLOAT ELSE 0 END) AS share_email_verified
FROM new_users
GROUP BY 1, 2
ORDER BY 1, 2
;