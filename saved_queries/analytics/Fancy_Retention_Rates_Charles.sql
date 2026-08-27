SELECT
    DATE_TRUNC('month', backend_created_at) AS quarter,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, session_start) = 0
        AND count_exit_data_entry > 0
        THEN clue_users.analytics_id END) * 1.0/
    NULLIF(COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, CURRENT_DATE) >= 0
        THEN clue_users.analytics_id END), 0) AS d0_tracking_rate,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, session_start) = 1
        AND DATE_DIFF('day', clue_users.backend_created_at, CURRENT_DATE) >= 1
        THEN clue_users.analytics_id END) * 1.0/
    NULLIF(COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, CURRENT_DATE) >= 1
        THEN clue_users.analytics_id END), 0) AS d1_retention_rate,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, session_start) BETWEEN 8 AND 14
        AND DATE_DIFF('day', clue_users.backend_created_at, CURRENT_DATE) >= 14
        THEN clue_users.analytics_id END) * 1.0/
    NULLIF(COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, CURRENT_DATE) >= 14
        THEN clue_users.analytics_id END), 0) AS w1_retention_rate,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, session_start) BETWEEN 31 AND 60
        AND DATE_DIFF('day', clue_users.backend_created_at, CURRENT_DATE) >= 60
        THEN clue_users.analytics_id END) * 1.0/
    NULLIF(COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, CURRENT_DATE) >= 60
        THEN clue_users.analytics_id END), 0) AS m2_retention_rate,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, session_start) BETWEEN 151 AND 180
        AND DATE_DIFF('day', clue_users.backend_created_at, CURRENT_DATE) >= 180
        THEN clue_users.analytics_id END) * 1.0/
    NULLIF(COUNT(DISTINCT CASE WHEN DATE_DIFF('day', clue_users.backend_created_at, CURRENT_DATE) >= 180
        THEN clue_users.analytics_id END), 0) AS m6_retention_rate
FROM core.clue_users
INNER JOIN user_metrics.user_first_session_attributes
    ON clue_users.analytics_id = user_first_session_attributes.analytics_id
LEFT JOIN der.sessions
    ON clue_users.analytics_id = sessions.analytics_id
    AND sessions.session_start > DATE(clue_users.backend_created_at)
    AND sessions.session_start >= DATE '2024-01-01'
LEFT JOIN user_metrics.user_subscription_status
    ON clue_users.analytics_id = user_subscription_status.analytics_id
WHERE
    user_first_session_attributes.platform = 'ios'
    AND user_first_session_attributes.country_name IN ('United Kingdom', 'Great Britain', 'Australia', 'Canada', 'New Zealand', 'United States')
    AND clue_users.backend_created_at >= DATE '2024-01-01'
    -- AND DATE_DIFF('day', clue_users.backend_created_at, conversion_ts) <= 30
GROUP BY 1
ORDER BY 1
;