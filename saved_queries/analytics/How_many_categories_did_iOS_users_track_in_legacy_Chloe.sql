WITH categories_per_session AS (
    SELECT
        CASE WHEN first_seen >= tracking.backend_created_at - '30 days'::INTERVAL THEN TRUE ELSE FALSE END 
            AS new_user,
        master_id,
        tracking.date,
        COUNT(DISTINCT category) AS unique_categories
    FROM der.tracking
    JOIN der.sp_users USING (master_id)
    WHERE tracking.backend_created_at BETWEEN '2022-10-01' AND '2022-11-01'
      AND sp_users.last_platform = 'ios'
      GROUP BY 1, 2, 3
),

cts AS (
    SELECT 
        CASE WHEN unique_categories > 10 THEN 10 ELSE unique_categories END AS unique_categories,
        COUNT(CASE WHEN new_user THEN 1 ELSE NULL END) as new_users,
        COUNT(CASE WHEN NOT new_user THEN 1 ELSE NULL END) as returning_users
    FROM categories_per_session
    GROUP BY 1 ORDER BY 1
),

total AS (
    SELECT SUM(new_users) AS total_new_users, SUM(returning_users) AS total_returning_users
    FROM cts
)

SELECT 
    *,
    100*new_users::FLOAT / total_new_users AS share_of_total_new_users,
    100*returning_users::FLOAT / total_returning_users AS share_of_total_returning_users
FROM cts
JOIN total ON 1=1
ORDER BY unique_categories