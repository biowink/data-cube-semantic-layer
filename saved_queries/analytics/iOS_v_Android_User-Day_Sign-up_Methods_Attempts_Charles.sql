WITH signups AS (
    SELECT
        master_id,
        platform,
        major_app_version,
        derived_tstamp::DATE AS date,
        NVL(NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'Authentication Method'), ''),
            JSON_EXTRACT_PATH_TEXT(event_properties, 'Method')) AS method,
                ROW_NUMBER() OVER (PARTITION BY master_id, date ORDER BY derived_tstamp ASC) AS rnk
    FROM der.events
    WHERE
        mobile_event_name IN ('Select Sign Up Method','Select Signup Method')
        AND derived_tstamp >= '2022-11-01'
), agg AS (
    SELECT
        master_id,
        platform,
        major_app_version,
        date,
            MAX(CASE WHEN rnk = 1 THEN method END) || MAX(CASE WHEN rnk = 2 THEN ' -> ' || method END) AS signup_path,
        MAX(rnk) AS count_sign_up_attempts,
        COUNT(DISTINCT NULLIF(method, '')) AS count_distinct_methods
    FROM signups
    GROUP BY 1, 2, 3, 4
)
SELECT platform,
       date,
       AVG(count_sign_up_attempts::FLOAT) AS avg_sign_up_attempts,
       AVG(count_distinct_methods::FLOAT) AS avg_sign_up_methods
FROM agg
GROUP BY 1, 2
ORDER BY 1, 2
;