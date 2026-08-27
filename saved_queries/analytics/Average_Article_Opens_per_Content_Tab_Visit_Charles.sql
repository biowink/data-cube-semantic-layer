
WITH article_events AS (
    SELECT
        analytics_id,
        session_id,
        platform,
        major_app_version,
        MIN(CASE WHEN events.mobile_event_name = 'Open Content Tab' THEN derived_tstamp END) AS content_tab_tstamp,
        MIN(CASE WHEN events.mobile_event_name = 'Open Article' THEN derived_tstamp END) AS article_tstamp,
        COUNT(DISTINCT CASE
                           WHEN events.mobile_event_name = 'Open Article'
                               THEN NULLIF(JSON_EXTRACT_SCALAR(event_properties, '$["Article ID"]'), '')
                       END) AS count_articles

    FROM der.events
    WHERE
        derived_tstamp >= CURRENT_DATE - INTERVAL '120' DAY
        AND major_app_version > 140
        AND platform IS NOT NULL
        AND mobile_event_name IN ('Open Content Tab', 'Open Article')
    GROUP BY
        1,
        2,
        3,
        4
)
SELECT article_events.platform,
       major_app_version,
       COUNT(*) AS count_users,
       AVG(count_articles * 1.0) AS avg_articles_read
FROM article_events
INNER JOIN der.users USING (analytics_id)
INNER JOIN der.subscription_history USING (analytics_id)
WHERE (article_tstamp IS NULL OR article_tstamp > content_tab_tstamp)
    AND content_tab_tstamp BETWEEN started_at AND expires_at
    AND DATE(account_created_at) < DATE(content_tab_tstamp)
GROUP BY 1, 2
HAVING count(*) > 10000
ORDER BY 1, 2
;