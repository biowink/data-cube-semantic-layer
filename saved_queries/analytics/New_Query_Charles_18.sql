WITH ios_sessions AS (
    SELECT
        analytics_id,
        major_app_version,
        DATE(session_start) AS date,
        COUNT(*) AS count_sessions
    FROM
        der.sessions
    WHERE
        session_start BETWEEN DATE '2024-09-01' AND DATE '2024-11-01'
        AND platform = 'android'
        AND product_tier = 'free'
    AND major_app_version BETWEEN 170 AND 180
        GROUP BY 1, 2, 3
),
        buy_screens AS (
SELECT
    ios_sessions.analytics_id,
        ios_sessions.major_app_version, date, COUNT (
    root_id) AS buy_screen_shows
FROM
    ios_sessions
LEFT JOIN der.events
ON ios_sessions.analytics_id = events.analytics_id AND DATE = DATE (derived_tstamp) AND mobile_event_name = 'View Subscription Plans' AND navigation_context = 'app open'
    AND derived_tstamp BETWEEN DATE '2024-09-01' AND DATE '2024-11-01'
WHERE
    count_sessions = 1
GROUP BY
    1, 2, 3
    )
SELECT date,
    major_app_version,
       AVG(CASE WHEN buy_screen_shows > 1 THEN 1.0 ELSE 0 END) AS double_rate
FROM buy_screens
GROUP BY 1, 2
ORDER BY 1,2
;