WITH info_text_users AS (
    SELECT
        user_first_session_attributes.platform,
        users.analytics_id,
        account_created_at,
        COUNT(DISTINCT events.analytics_id) AS d0_info_text
    FROM
        der.users
        INNER JOIN user_metrics.user_first_session_attributes
            ON users.analytics_id = user_first_session_attributes.analytics_id
        LEFT JOIN der.events ON users.analytics_id = events.analytics_id AND
                                (events.mobile_event_name = 'Open Tracking Info Modal' OR
                                 (mobile_event_name = 'View Subscription Plans' AND
                                  navigation_context LIKE '%info text%')) AND
                                derived_tstamp BETWEEN DATE ('2024-05-01') AND DATE ('2024-12-31')
                AND DATE_DIFF('day', account_created_at, derived_tstamp) BETWEEN 0 AND 30
WHERE
    user_first_session_attributes.platform IS NOT NULL
    AND account_created_at BETWEEN DATE ('2024-05-01')
    AND DATE ('2024-10-31')
GROUP BY
    1, 2, 3
    )
SELECT CASE WHEN d0_info_text = 1 THEN 'Opened Info Text' ELSE 'Did Not Open Info Text' END AS info_text,
       DATE_TRUNC('month', account_created_at) AS month,
        COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT info_text_users.analytics_id) AS mau_retention_rate
FROM info_text_users
LEFT JOIN der.sessions ON info_text_users.analytics_id = sessions.analytics_id AND
                        DATE_DIFF('day', account_created_at, session_start) BETWEEN 31 AND 60
                       AND session_start >= DATE('2024-05-01')
GROUP BY 1, 2
ORDER BY 1, 2
;