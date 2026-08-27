WITH second_sessions AS (
    SELECT master_id, min(start) as first_seen_at
    FROM der.sp_sessions
    WHERE session_index = 2 AND is_subscribed is not true
    AND platform = 'ios'
    AND start between current_date - '91 days'::interval and current_date - '1 day'::interval 
    GROUP BY 1
),

first_date AS (
    SELECT DATE_TRUNC('day', MIN(first_seen_at)) as first_date
    FROM second_sessions
),

users_by_day AS (
    SELECT
        DATE_TRUNC('day', first_seen_at) as first_seen_at,
        COUNT(master_id) as users
    FROM second_sessions 
    GROUP BY 1
)

SELECT
    first_seen_at,
    first_seen_at - first_date as dt,
    users as new_users,
    SUM(users) OVER (ORDER BY first_seen_at ROWS UNBOUNDED PRECEDING) as cumulative_users

FROM users_by_day
JOIN first_date ON (1=1)
ORDER BY dt
