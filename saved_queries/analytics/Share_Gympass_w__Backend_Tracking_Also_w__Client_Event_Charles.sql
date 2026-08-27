
WITH activity AS (
    SELECT
        DATE_TRUNC('day', tracked_at) AS date,
        analytics_id,
        MAX(CASE WHEN clue_event_name = 'tracking.event' THEN 1 ELSE 0 END) AS backend_tracking,
        MAX(CASE WHEN clue_event_name != 'tracking.event' THEN 1 ELSE 0 END) AS client_activity
    FROM der.backend_gympass_event_tracked
    WHERE
        tracked_at >= '2024-01-01'
    GROUP BY 1, 2
    )
SELECT date,
       AVG(client_activity::FLOAT)
FROM activity
WHERE backend_tracking = 1
GROUP BY 1
ORDER BY 1
;