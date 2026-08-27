WITH months AS (
    SELECT DISTINCT DATE_TRUNC('month', first_seen) AS month
    FROM der.sp_users
    WHERE month >= '2020-01-01'
),
    mau AS (
    SELECT DISTINCT DATE_TRUNC('month', start) AS month,
                    master_id
    FROM der.sp_sessions
    WHERE user_first_seen >= '2020-01-01'
)
SELECT DATE_TRUNC('month', first_seen) AS month_cohort,
       months.month,
       DATEDIFF('month', month_cohort, months.month) AS months_into_lifecycle,
       COUNT(sp_users.master_id) AS count_users,
       COUNT(CASE WHEN DATE_TRUNC('month', user_first_converted_at) <= months.month THEN sp_users.master_id END) AS count_converted_to_paid,
       count_converted_to_paid::FLOAT/count_users AS running_paid_conversion_rate,
       COUNT(mau.master_id) AS count_mau,
       count_mau::FLOAT/count_users AS mau_rate
FROM der.sp_users
CROSS JOIN months
LEFT JOIN der.subscription_history
    ON sp_users.master_id = subscription_history.master_id AND subscription_history.user_converted_with_this_subscription
LEFT JOIN mau ON mau.master_id = sp_users.master_id AND months.month = mau.month
WHERE NOT is_test_user 
AND first_seen >= '2020-01-01' 
AND month_cohort <= months.month
AND months.month < DATE_TRUNC('month', CURRENT_DATE)
AND first_country_name = 'United States'
AND first_platform = 'ios'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;