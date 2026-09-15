WITH chat_users AS (
SELECT
    analytics_id,
    COUNT(DISTINCT CASE WHEN events.mobile_event_name = 'Submit Chat With Your Data Query'
        THEN session_id END) AS count_sessions
FROM der.events
INNER JOIN core.clue_users USING (analytics_id)
WHERE
    derived_tstamp >= DATE '2026-07-16'
    AND NOT COALESCE(is_internal_user, FALSE)
    AND mobile_event_name IN (
        'Open Chat With Your Data Conversation',
        'Submit Chat With Your Data Query')
GROUP BY 1
)
SELECT
       COUNT(*) AS count_users,
       SUM(CASE WHEN count_sessions > 1 THEN 1 ELSE 0 END) AS count_users_with_second_query_session,
       AVG(CASE WHEN count_sessions > 1 THEN 1.0 ELSE 0 END) AS count_users_with_second_query_session
FROM chat_users
;