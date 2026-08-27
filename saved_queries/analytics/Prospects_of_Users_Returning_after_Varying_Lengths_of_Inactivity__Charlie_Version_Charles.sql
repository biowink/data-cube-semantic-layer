WITH session_days AS (
SELECT
    session_id,
    analytics_id,
    account_created_at,
    session_start::DATE AS session_start_dt
FROM der.sessions
JOIN der.users USING(analytics_id)
WHERE session_start BETWEEN '2022-09-01' AND current_date - '120 days'::INTERVAL
),
next_active_day AS (
SELECT
    session_id,
    account_created_at,
    session_start_dt,
    LEAD(session_start_dt) OVER (PARTITION BY analytics_id ORDER BY session_start_dt) AS next_session_start_dt
FROM session_days
),
days_to_next_active_day AS (
SELECT *,
    DATEDIFF('day', account_created_at, session_start_dt) as days_since_account_created,
    DATEDIFF('day', session_start_dt, next_session_start_dt) as days_to_next_session
FROM next_active_day
),
integer_array AS (
SELECT ROW_NUMBER() OVER (ORDER BY date) AS index
FROM static.calendar
LIMIT 90
)
SELECT
    CASE WHEN days_since_account_created = 0 THEN 'D0'
         WHEN days_since_account_created <= 30 THEN 'M0'
         ELSE 'D31+'
         END as age,
    index,
    AVG(CASE WHEN days_to_next_session <= index THEN 1::FLOAT ELSE 0 END) AS share_having_returned_within_n_days,
    AVG(CASE WHEN index >= 90 THEN NULL
            WHEN days_to_next_session <= index + 30 AND NVL(days_to_next_session, 999) > index THEN 1::FLOAT 
            WHEN NVL(days_to_next_session, 999) > index THEN 0 END) AS share_not_having_returned_but_will_return_in_next_30d
FROM days_to_next_active_day
CROSS JOIN integer_array
WHERE MOD(index, 7) = 1 
GROUP BY 1, 2
ORDER BY 1, 2