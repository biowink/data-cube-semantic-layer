WITH years AS (
    SELECT DISTINCT DATE_TRUNC('year', first_purchased_at) AS year
    FROM der.subscription_history
    WHERE first_purchased_at >= '2020-01-01'
)
SELECT EXTRACT('year' from first_seen) AS first_seen_year,
        year,
       COUNT(DISTINCT sp_users.user_id) AS active_users,
       COUNT(DISTINCT CASE WHEN DATE_TRUNC('year', first_purchased_at) <= year THEN sp_users.user_id END)::FLOAT/COUNT(DISTINCT sp_users.user_id) AS cumulative_conversion_to_paid
FROM der.sp_users
LEFT JOIN der.subscription_history ON sp_users.user_id = subscription_history.user_id
                                          AND subscription_history.user_converted_with_this_subscription
CROSS JOIN years
WHERE first_country_name = 'United States'
GROUP BY 1, 2
HAVING cumulative_conversion_to_paid > 0
ORDER BY 1, 2
;