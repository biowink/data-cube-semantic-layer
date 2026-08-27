WITH second_sessions AS (
    SELECT
        analytics_id,
        MIN(session_start) AS second_session_ts
    FROM
        user_metrics.user_first_session_attributes
    INNER JOIN
        der.sessions USING (analytics_id)
    INNER JOIN
        der.profiles USING (analytics_id)
    INNER JOIN
        user_metrics.user_last_optional_consent_status USING (analytics_id)
    WHERE
        session_ts >= DATE '2024-07-01'
        AND session_start >= DATE '2024-07-01'
        AND session_start > DATE_ADD('minute', 5, session_ts)
        AND consent_scientific_research_revoke_ts IS NULL
        AND consent_health_analytics_revoke_ts IS NULL
        AND DATE_DIFF('year', birthday, CURRENT_DATE) BETWEEN 18 AND 45
    GROUP BY
        1
),
    filtered_second_sessions AS (
        SELECT sessions.analytics_id, second_session_ts
        FROM
            second_sessions
        INNER JOIN
            der.sessions ON second_sessions.analytics_id = sessions.analytics_id
            AND second_sessions.second_session_ts = sessions.session_start
        WHERE
            mode = 'period tracking'
            AND language = 'English'
            AND country_name = 'United States'
            AND product_tier = 'free'
            AND session_start >= DATE '2025-01-01'
            AND second_session_ts >= DATE '2025-01-01'
    )
SELECT DATE(second_session_ts) AS date,
    COUNT(*) AS count_eligible_users
FROM filtered_second_sessions
GROUP BY 1
ORDER BY 1
;