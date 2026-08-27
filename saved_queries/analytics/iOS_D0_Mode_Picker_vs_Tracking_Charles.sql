WITH day_zero AS (
    SELECT
        master_id,
        first_seen,
        first_platform,
        MIN(CASE WHEN mobile_event_name = 'Did Create Account' THEN derived_tstamp END) AS create_account_ts,
        MIN(CASE
                WHEN mobile_event_name = 'Open Data Entry'
                    THEN derived_tstamp
            END) AS open_data_entry_ts,
        MIN(CASE
                WHEN mobile_event_name = 'Open Mode Picker'
                    THEN derived_tstamp
            END) AS open_mode_picker_ts,
        MIN(CASE
                WHEN mobile_event_name IN ('Open Mode Picker', 'Open Data Entry')                    
                    THEN derived_tstamp
            END) AS open_something_ts
    FROM der.sp_users
    INNER JOIN der.events
            USING (master_id)
    WHERE
        DATEDIFF('day', first_seen, derived_tstamp) = 0
        AND derived_tstamp >= '2022-11-01'
        AND first_seen >= '2022-11-01'
        AND mobile_event_name IN ('Did Create Account', 'Open Data Entry', 'Open Mode Picker')
        AND first_platform = 'ios'
    GROUP BY 1, 2, 3
)
SELECT first_seen::DATE AS date,
       first_platform,
       AVG(CASE WHEN open_data_entry_ts > create_account_ts THEN 1::FLOAT ELSE 0 END) AS open_data_entry_rate,
       AVG(CASE WHEN open_something_ts > create_account_ts THEN 1::FLOAT ELSE 0 END) AS open_something_rate
FROM day_zero
WHERE create_account_ts IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;