WITH day_zero AS (
    SELECT
        master_id,
        first_seen,
        first_platform,
        MIN(CASE WHEN mobile_event_name = 'Did Create Account' THEN derived_tstamp END) AS create_account_ts,
        MIN(CASE WHEN mobile_event_name = 'Open Data Entry' THEN derived_tstamp END) AS open_data_entry_ts,
        MIN(CASE WHEN mobile_event_name IN ('Email Verified','Did Authenticate Social Account') THEN derived_tstamp END) AS email_verified_ts,
        MAX(CASE
                WHEN mobile_event_name = 'Exit Data Entry' AND
                     CASE WHEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') != ''
                     THEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points')::INT END > 0
                    THEN derived_tstamp
            END) AS exit_data_entry_ts,
        
        SUM(NVL(CASE
                WHEN mobile_event_name = 'Exit Data Entry' AND
                     CASE WHEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') != ''
                     THEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points')::INT END > 0
                    THEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points')::INT
            END, 0)) AS total_data_points_tracked
    FROM der.sp_users
    INNER JOIN der.events
            USING (master_id)
    WHERE
        DATEDIFF('day', first_seen, derived_tstamp) = 0
        AND derived_tstamp BETWEEN '2023-03-15' AND CURRENT_DATE - 1
        AND first_seen BETWEEN '2023-03-15' AND CURRENT_DATE - 1
        AND mobile_event_name IN ('Did Create Account', 'Exit Data Entry', 'Open Data Entry', 'Email Verified','Did Authenticate Social Account')
    GROUP BY 1, 2, 3
)
SELECT first_platform,
COUNT(*),
       AVG(CASE WHEN email_verified_ts IS NOT NULL THEN 1::FLOAT ELSE 0 END) AS share_verifying_day_zero,
       AVG(CASE WHEN open_data_entry_ts IS NOT NULL THEN 1::FLOAT ELSE 0 END) AS share_open_data_entry_zero
FROM day_zero
WHERE create_account_ts IS NOT NULL
GROUP BY 1
;