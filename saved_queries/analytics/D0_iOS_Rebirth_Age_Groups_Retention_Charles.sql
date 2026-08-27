WITH age_grouped_users AS (
    SELECT
        analytics_id,
        platform,
        account_created_at,
        CASE
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 12 AND 19 THEN '12-19 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 20 AND 24 THEN '20-24 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 25 AND 29 THEN '25-29 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 30 AND 39 THEN '30-39 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 40 AND 49 THEN '40-49 Year Olds'
        END AS age_group
    FROM
        der.users
        INNER JOIN der.profiles USING (analytics_id)
        INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
    WHERE
        DATE_DIFF('year', birthday, account_created_at) BETWEEN 10 AND 50
        AND account_created_at BETWEEN DATE '2023-05-01' AND DATE '2023-07-01'
        AND user_first_session_attributes.platform = 'ios'
)
SELECT age_group,
       COUNT(DISTINCT age_grouped_users.analytics_id) AS cohort_size,
       COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT age_grouped_users.analytics_id) AS retention_rate
FROM age_grouped_users
LEFT JOIN der.sessions ON age_grouped_users.analytics_id = sessions.analytics_id
    AND session_start >= DATE '2023-05-01'
    AND DATE_DIFF('day', account_created_at, session_start) = 1
GROUP BY 1
ORDER BY 1
;