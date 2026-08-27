WITH day_zero AS (
    SELECT
        master_id,
        first_seen,
        first_platform,
        MIN(CASE WHEN mobile_event_name = 'Did Create Account' THEN derived_tstamp END) AS create_account_ts,
        MIN(CASE WHEN mobile_event_name = 'Open Data Entry' THEN derived_tstamp END) AS open_data_entry_ts,
        MAX(CASE
                WHEN mobile_event_name = 'Exit Data Entry' AND
                     CASE WHEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') != ''
                     THEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points')::INT END > 0
                    THEN derived_tstamp
            END) AS create_tracking_point_ts, 
        MAX(derived_tstamp) AS latest_ts
    FROM der.sp_users
    INNER JOIN der.events
            USING (master_id)
    WHERE
        DATEDIFF('day', first_seen, derived_tstamp) IN (0, 1)
        AND derived_tstamp >= '2022-11-01'
        AND first_seen >= '2022-11-01'
        AND mobile_event_name IN ('Did Create Account', 'Open Cycle View', 'Open Data Entry', 'Exit Data Entry')
    GROUP BY 1, 2, 3
)
SELECT first_seen::DATE AS date,
       first_platform,
       AVG(CASE WHEN DATEDIFF('day', first_seen, create_account_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS first_seen_to_d0_did_create_account,
       AVG(CASE WHEN DATEDIFF('day', first_seen, open_data_entry_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS first_seen_to_d0_did_open_data_entry,
       AVG(CASE WHEN DATEDIFF('day', open_data_entry_ts, create_tracking_point_ts) = 0 
       AND DATEDIFF('day', first_seen, open_data_entry_ts) = 0 THEN 1::FLOAT ELSE 0 END) AS d0_did_open_data_entry_to_create_tracking_point,
       AVG(CASE WHEN DATEDIFF('day', first_seen, latest_ts) = 1 THEN 1::FLOAT ELSE 0 END) AS first_seen_to_d1_event
FROM day_zero
GROUP BY 1, 2
ORDER BY 1, 2
;