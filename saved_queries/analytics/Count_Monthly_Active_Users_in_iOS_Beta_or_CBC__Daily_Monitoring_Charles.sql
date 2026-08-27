WITH cbc_beta AS (
    SELECT master_id, MAX(session_start) AS most_recent_session
    FROM der.sessions
    WHERE (mode = 'clue birth control'
       OR major_app_version = 100)
        AND session_start >= '2023-01-01'
        AND platform = 'ios'
    GROUP BY 1
),
    session_days AS (
        SELECT
            master_id,
            session_start::DATE AS date,
            LAST_VALUE(major_app_version IGNORE NULLS)
            OVER (PARTITION BY master_id, session_start::DATE ORDER BY session_start ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS major_app_version,
            LAST_VALUE(mode IGNORE NULLS)
            OVER (PARTITION BY master_id, session_start::DATE ORDER BY session_start ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS mode,
            ROW_NUMBER() OVER (PARTITION BY master_id, session_start::DATE ORDER BY session_start DESC) AS rnk
        FROM cbc_beta
        INNER JOIN der.sessions
                USING (master_id)
        WHERE
            session_start >= '2023-01-01'
    ),
    daily_status AS (
    SELECT
        master_id,
        date,
                FIRST_VALUE(major_app_version IGNORE NULLS)
                OVER (PARTITION BY master_id ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS major_app_version,
                FIRST_VALUE(mode IGNORE NULLS)
                OVER (PARTITION BY master_id ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS mode,
                COUNT(session_days.date)
                OVER (PARTITION BY master_id ORDER BY date ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS active_days,
        active_days > 0 AS is_mau
    FROM cbc_beta
    CROSS JOIN static.calendar
    LEFT JOIN session_days
            USING (master_id, date)
    WHERE
        calendar.date BETWEEN '2023-01-01' AND CURRENT_DATE - 1
        AND (rnk = 1 OR rnk IS NULL)
)
SELECT date,
       COUNT(*) AS count_unmigrated_users
FROM daily_status
WHERE date >= '2023-02-01'
  AND is_mau
  AND (major_app_version = 100
  OR mode = 'clue birth control')
GROUP BY 1
ORDER BY 1
;