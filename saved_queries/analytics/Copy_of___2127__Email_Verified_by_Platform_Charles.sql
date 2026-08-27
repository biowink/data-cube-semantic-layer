WITH email_accounts AS (
    SELECT
        master_id,
        platform,
        derived_tstamp
    FROM der.events
    WHERE
        mobile_event_name = 'Did Create Account'
        AND JSON_EXTRACT_PATH_TEXT(event_properties, 'Method') ||
            JSON_EXTRACT_PATH_TEXT(event_properties, 'Authentication Method') = 'email'
        AND derived_tstamp >= '2022-11-01'
)
SELECT email_accounts.platform,
       email_accounts.derived_tstamp::DATE,
       COUNT(DISTINCT email_accounts.master_id) AS count_email_accounts,
       COUNT(DISTINCT events.master_id) AS count_verified,
       count_verified::FLOAT/count_email_accounts AS share_verified
FROM email_accounts
LEFT JOIN der.events ON DATEDIFF('day', email_accounts.derived_tstamp, events.derived_tstamp) = 0
    AND email_accounts.master_id = events.master_id AND events.mobile_event_name = 'Email Verified'
GROUP BY 1, 2
ORDER BY 1, 2
;