WITH sessions_subset AS (
    SELECT
        *
    FROM der.sessions
    WHERE session_start BETWEEN date '2025-09-01' and date '2025-10-01'
),

join_to_past_sessions AS (
    SELECT
        sessions_subset.session_id,
        sessions_subset.analytics_id,
        sessions_subset.session_start,
        sessions.session_start AS last_session_start
    FROM sessions_subset
    JOIN der.sessions
      ON (sessions_subset.previous_session_id = sessions.session_id)
)

SELECT
    COUNT(session_id),
    COUNT(last_session_start)
FROM join_to_past_sessions;

