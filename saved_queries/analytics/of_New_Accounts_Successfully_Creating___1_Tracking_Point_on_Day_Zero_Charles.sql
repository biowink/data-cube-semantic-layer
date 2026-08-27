WITH day_zero AS (
    SELECT
        master_id,
        first_seen,
        first_platform,
        MIN(CASE WHEN mobile_event_name = 'Did Create Account' THEN derived_tstamp END) AS create_account_ts,
        MAX(CASE
                WHEN mobile_event_name = 'Exit Data Entry' AND
                     CASE WHEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') != ''
                     THEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points')::INT END > 0
                    THEN derived_tstamp
            END) AS exit_data_entry_ts
    FROM der.sp_users
    INNER JOIN der.events
            USING (master_id)
    WHERE
        DATEDIFF('day', first_seen, derived_tstamp) = 0
        AND derived_tstamp >= '2022-11-01'
        AND first_seen >= '2022-11-01'
        AND mobile_event_name IN ('Did Create Account', 'Exit Data Entry')
    GROUP BY 1, 2, 3
)
SELECT first_seen::DATE AS date,
       first_platform,
       AVG(CASE WHEN exit_data_entry_ts > create_account_ts THEN 1::FLOAT ELSE 0 END) AS funnel_completion_rate
FROM day_zero
WHERE create_account_ts IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;