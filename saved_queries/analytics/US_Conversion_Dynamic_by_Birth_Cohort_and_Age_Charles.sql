WITH years AS (
    SELECT DISTINCT DATE_TRUNC('year', first_purchased_at) AS year
    FROM der.subscription_history
    WHERE first_purchased_at >= '2020-01-01'
),
    yau AS (
        SELECT DISTINCT user_id,
                        DATE_TRUNC('year', start) AS active_year
        FROM der.sp_sessions
        WHERE start >= '2020-01-01'
    )
SELECT year,
       birth_year,
       EXTRACT('year' from year) - birth_year AS age,
       COUNT(DISTINCT sp_users.user_id) AS active_users,
       COUNT(DISTINCT CASE WHEN DATE_TRUNC('year', first_purchased_at) <= year THEN sp_users.user_id END)::FLOAT/COUNT(DISTINCT sp_users.user_id) AS cumulative_conversion_to_paid
FROM der.sp_users
LEFT JOIN der.subscription_history ON sp_users.user_id = subscription_history.user_id
                                          AND subscription_history.user_converted_with_this_subscription
CROSS JOIN years
-- INNER JOIN yau ON sp_users.user_id = yau.user_id AND years.year = yau.active_year
WHERE first_country_name = 'United States' AND first_seen::DATE + 365 < year
GROUP BY 1, 2, 3
HAVING active_users >= 10000
ORDER BY 1, 2, 3
;