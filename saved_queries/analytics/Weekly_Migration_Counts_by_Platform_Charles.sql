WITH switches AS (
    SELECT
        analytics_id,
        platform,
        DATE_TRUNC('week', derived_tstamp) AS week,
        MIN(major_app_version) AS min_major_app_version,
        MAX(major_app_version) AS max_major_app_version
    FROM der.events
    WHERE
        derived_tstamp >= '2023-05-01'
    GROUP BY 1, 2, 3
)
SELECT platform,
       week,
       COUNT(DISTINCT analytics_id) AS count
FROM switches
WHERE min_major_app_version < 100 AND max_major_app_version > 100
GROUP BY 1, 2
ORDER BY 1, 2
;