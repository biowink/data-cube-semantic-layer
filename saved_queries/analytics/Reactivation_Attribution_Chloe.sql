INSERT INTO intermediate.reactivation_sessions (
    session_id,
    analytics_id,
    session_start,
    last_session_start,
    days_since_previous_session
)
WITH new_sessions AS (
    SELECT
        session_id,
        analytics_id,
        session_start
    FROM der.sessions
    WHERE session_start BETWEEN date '2025-05-01' and date '2025-06-01'
),

sessions AS (
    SELECT
        session_id,
        analytics_id,
        session_start
    FROM der.sessions
    WHERE session_start < date '2025-06-01'
),

join_to_past_sessions AS (
    SELECT
        new_sessions.session_id,
        new_sessions.analytics_id,
        new_sessions.session_start,
        MAX(sessions.session_start) AS last_session_start
    FROM new_sessions
    JOIN sessions
      ON (new_sessions.analytics_id = sessions.analytics_id
          AND new_sessions.session_start > sessions.session_start)
    GROUP BY 1, 2, 3
)

SELECT
    session_id,
    analytics_id,
    session_start,
    last_session_start,
    DATE_DIFF('day', last_session_start, session_start) AS days_since_previous_session
FROM join_to_past_sessions
WHERE last_session_start IS NOT NULL AND DATE_DIFF('day', last_session_start, session_start) >= 50
;