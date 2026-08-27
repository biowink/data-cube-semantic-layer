WITH email_accounts AS (
    SELECT
        users.analytics_id,
        users.backend_created_at,
        COUNT(events.analytics_id) AS count_did_create_account
    FROM import.users
    LEFT JOIN der.events ON users.analytics_id = events.analytics_id
        AND mobile_event_name = 'Did Create Account'
        AND JSON_EXTRACT_PATH_TEXT(event_properties, 'Method') ||
            JSON_EXTRACT_PATH_TEXT(event_properties, 'Authentication Method') = 'email'
    WHERE users.backend_created_at >= '2023-02-01'
    GROUP BY 1, 2
)
SELECT email_accounts.backend_created_at::DATE,
        COUNT(DISTINCT email_accounts.analytics_id) AS count_users,
        COUNT(DISTINCT CASE WHEN count_did_create_account > 0 THEN email_accounts.analytics_id END) AS count_email_users,
       AVG(count_did_create_account::FLOAT) AS avg_events,
       count_email_users::FLOAT/count_users
FROM email_accounts
GROUP BY 1
ORDER BY 1
;