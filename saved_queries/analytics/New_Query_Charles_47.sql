WITH android_new_accounts AS (
    SELECT
        analytics_id,
        major_app_version,
        MIN(derived_tstamp) AS create_account_ts
    FROM der.events
    WHERE
        platform = 'android'
        AND derived_tstamp >= CURRENT_DATE - 14
        AND mobile_event_name = 'Did Create Account'
        AND major_app_version IN (122, 123)
    GROUP BY 1, 2
),
    user_counts AS (
        SELECT major_app_version, COUNT(*) AS total_user_count
        FROM android_new_accounts
        GROUP BY 1
    )
SELECT android_new_accounts.major_app_version,
       mobile_event_name,
       COUNT(*) AS event_count,
       COUNT(DISTINCT analytics_id) AS user_count,
       user_count::FLOAT/total_user_count
FROM android_new_accounts
LEFT JOIN der.events USING (analytics_id, major_app_version)
INNER JOIN user_counts USING (major_app_version)
WHERE derived_tstamp::DATE = create_account_ts::DATE
  AND derived_tstamp > create_account_ts
GROUP BY 1, 2, total_user_count
ORDER BY 1, 5 DESC
;