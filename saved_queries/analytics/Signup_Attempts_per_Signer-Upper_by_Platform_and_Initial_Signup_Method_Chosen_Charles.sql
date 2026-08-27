WITH signups AS (
    SELECT
        master_id,
        platform,
        derived_tstamp,
        JSON_EXTRACT_PATH_TEXT(event_properties, 'Authentication Method') AS authentication_method,
                ROW_NUMBER() OVER (PARTITION BY master_id, platform ORDER BY derived_tstamp ASC) AS rnk
    FROM der.events
    WHERE
        derived_tstamp >= CURRENT_DATE - 30
        AND major_app_version > 100
        AND mobile_event_name = 'Select Sign Up Method'
),
    agg AS (
        SELECT
            master_id,
            platform,
            MAX(CASE WHEN rnk = 1 THEN authentication_method END) AS first_signup_method,
            COUNT(*) AS count_attempts
        FROM signups
        GROUP BY 1, 2
    )
SELECT NVL(NULLIF(first_signup_method, ''), 'SIGNUP METHOD EMPTY') AS first_signup_method,
       platform,
       COUNT(*) AS count,
       AVG(count_attempts::FLOAT) AS avg_attempts,
       AVG(CASE WHEN count_attempts > 1 THEN 1::FLOAT ELSE 0 END) * 100 AS share_users_with_multiple_attempts
FROM agg
GROUP BY 1, 2
ORDER BY 1, 2
;