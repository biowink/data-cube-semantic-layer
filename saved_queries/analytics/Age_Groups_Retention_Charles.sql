WITH age_grouped_users AS (
    SELECT
        analytics_id,
        platform,
        account_created_at,
        CASE
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 10 AND 17 THEN '10-17 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 18 AND 24 THEN '18-24 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 25 AND 32 THEN '25-32 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 33 AND 39 THEN '33-39 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 40 AND 50 THEN '40-50 Year Olds'
        END AS age_group
    FROM
        der.users
        INNER JOIN der.profiles USING (analytics_id)
        INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
    WHERE
        DATE_DIFF('year', birthday, account_created_at) BETWEEN 10 AND 50
        AND account_created_at BETWEEN DATE '2022-01-01' AND DATE '2022-07-01'
        AND user_first_session_attributes.platform = 'android'
)
SELECT age_group,
       months_into_lifecycle,
       COUNT(DISTINCT age_grouped_users.analytics_id) AS cohort_size,
       COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT age_grouped_users.analytics_id) AS retention_rate
FROM age_grouped_users
CROSS JOIN (SELECT (ROW_NUMBER() OVER (ORDER BY date) - 1) * 6 AS months_into_lifecycle FROM static.calendar LIMIT 6) AS month_indices
LEFT JOIN der.sessions ON age_grouped_users.analytics_id = sessions.analytics_id
    AND session_start >= DATE '2022-01-01'
    AND session_start >= DATE(account_created_at)
    AND DATE_DIFF('month', account_created_at, session_start) = months_into_lifecycle
GROUP BY 1, 2
ORDER BY 1, 2
;