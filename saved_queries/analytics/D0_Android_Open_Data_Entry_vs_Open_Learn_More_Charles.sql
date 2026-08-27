WITH android_new_accounts AS (
    SELECT
        analytics_id,
        major_app_version,
        MIN(derived_tstamp) AS create_account_ts
    FROM der.events
    WHERE
        platform = 'android'
        AND derived_tstamp >= CURRENT_DATE - 120
        AND mobile_event_name = 'Did Create Account'
        AND major_app_version >= 105
    GROUP BY 1, 2
),
    user_counts AS (
        SELECT major_app_version, COUNT(*) AS total_user_count
        FROM android_new_accounts
        GROUP BY 1
    )
        SELECT
            android_new_accounts.major_app_version,
            COUNT(DISTINCT analytics_id) AS user_count,
            COUNT(DISTINCT CASE WHEN mobile_event_name IN ('Open Data Entry') THEN analytics_id END)::FLOAT/user_count AS open_date_entry_rate,
            COUNT(DISTINCT CASE WHEN mobile_event_name IN ('Open Learn More') THEN analytics_id END)::FLOAT/user_count AS open_learn_more_rate,
            COUNT(DISTINCT CASE WHEN mobile_event_name IN ('Open Data Entry', 'Open Learn More')
                THEN analytics_id END)::FLOAT/user_count AS date_entry_learn_more_user_count
        FROM android_new_accounts
        LEFT JOIN der.events
                USING (analytics_id, major_app_version)
        WHERE
            derived_tstamp::DATE = create_account_ts::DATE
            AND derived_tstamp > create_account_ts
            AND derived_tstamp >= CURRENT_DATE - 120
        GROUP BY 1
        HAVING user_count > 10000
ORDER BY 1
;