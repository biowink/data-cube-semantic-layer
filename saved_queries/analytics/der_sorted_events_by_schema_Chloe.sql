WITH cts AS (
    SELECT
        schema_name,
        COUNT(root_id) AS events
    FROM der.sorted_events
    WHERE derived_tstamp >= '2022-01-01'
    GROUP BY 1
    ORDER BY 2 DESC
),

total AS (
    SELECT SUM(events) as total_events
    FROM cts
)

SELECT
    *, events::float/total_events as share
FROM cts
JOIN total ON 1=1