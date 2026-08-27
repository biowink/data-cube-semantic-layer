WITH age_grouped_users AS (
    SELECT
        analytics_id,
        platform,
        account_created_at,
        CASE
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 12 AND 15 THEN '12-15 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 16 AND 19 THEN '16-19 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 20 AND 29 THEN '20-29 Year Olds'
            WHEN DATE_DIFF('year', birthday, account_created_at) BETWEEN 30 AND 49 THEN '30-49 Year Olds'
        END AS age_group
    FROM
        der.users
        INNER JOIN der.profiles USING (analytics_id)
        INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
    WHERE
        DATE_DIFF('year', birthday, account_created_at) BETWEEN 12 AND 49
        AND account_created_at BETWEEN DATE '2024-01-01' AND DATE '2025-03-01'
        AND user_first_session_attributes.platform = 'android'
)
SELECT age_group,
        DATE_TRUNC('month', account_created_at) AS month,
       COUNT(DISTINCT age_grouped_users.analytics_id) AS cohort_size,
       AVG(CASE WHEN count_d7_tracking_points >= 5 AND count_d7_tracking_days >= 1 THEN 1.0 ELSE 0 END) AS activation_rate
FROM age_grouped_users
LEFT JOIN user_metrics.new_user_activation_metrics ON age_grouped_users.analytics_id = new_user_activation_metrics.analytics_id
GROUP BY 1, 2
ORDER BY 1, 2
;