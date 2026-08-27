WITH accounts AS (
    SELECT
        sp_device_id,
        major_app_version,
        MIN(derived_tstamp) AS account_creation_tstamp
    FROM der.events
    WHERE
        platform = 'android'
        AND mobile_event_name = 'Did Create Account'
        AND derived_tstamp >= '2023-01-01'
    GROUP BY 1, 2
)
SELECT account_creation_tstamp::DATE,
       COUNT(DISTINCT accounts.sp_device_id) AS new_accounts,
       COUNT(DISTINCT sessions.sp_device_id) AS d1_retained,
       d1_retained::FLOAT/new_accounts AS d1_retention_rate
FROM accounts
LEFT JOIN der.sessions ON accounts.sp_device_id = sessions.sp_device_id 
                              AND DATEDIFF('day', account_creation_tstamp, session_start) = 1
GROUP BY 1
ORDER BY 1
;