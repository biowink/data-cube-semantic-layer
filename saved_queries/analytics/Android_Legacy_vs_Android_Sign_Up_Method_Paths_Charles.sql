WITH signups AS (
    SELECT
        master_id,
        platform,
        major_app_version,
        derived_tstamp::DATE AS date,
        NVL(NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'Authentication Method'), ''),
            JSON_EXTRACT_PATH_TEXT(event_properties, 'Method')) AS method,
                ROW_NUMBER() OVER (PARTITION BY master_id, date ORDER BY derived_tstamp ASC) AS rnk,
                ROW_NUMBER() OVER (PARTITION BY master_id, date ORDER BY derived_tstamp DESC) AS reverse_rnk
    FROM der.events
    WHERE
        mobile_event_name IN ('Select Sign Up Method','Select Signup Method')
        AND derived_tstamp >= '2022-11-01'
), agg AS (
    SELECT
        master_id,
        platform,
        major_app_version > 100 AS is_rebirth,
        date,
       MAX(rnk) AS total_methods,
       MAX(CASE WHEN rnk = 1 THEN method END) AS first_method,
       MAX(CASE WHEN reverse_rnk = 1 THEN method END) AS last_method
    FROM signups
    GROUP BY 1, 2, 3, 4
)
SELECT is_rebirth,
       CASE WHEN total_methods = 1 THEN first_method ELSE first_method || ' -> ' || last_method END AS method_path,
       COUNT(*)::FLOAT/total_users AS share_total
FROM agg
LEFT JOIN (SELECT is_rebirth, COUNT(*) AS total_users
           FROM agg WHERE platform = 'android' GROUP BY 1) USING (is_rebirth)
WHERE platform = 'android'
GROUP BY 1, 2, total_users
HAVING share_total > .001
ORDER BY 1, 3 DESC
;