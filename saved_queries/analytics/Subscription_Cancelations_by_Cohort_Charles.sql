WITH dates AS (
    SELECT DISTINCT started_at::DATE AS date FROM der.subscription_history WHERE started_at > '2021-01-01'
)
SELECT DATE_TRUNC('month',date) AS week,
       DATE_TRUNC('quarter', first_purchased_at) AS sub_start_quarter,
       SUM(1) AS active_subs,
       SUM(CASE WHEN date > NVL(subscription_history.last_canceled_at::DATE, '9999-01-01') THEN 1 END) AS canceled_subs,
       SUM(CASE WHEN last_canceled_at::DATE = date THEN 1 END) AS cancelations,
       canceled_subs::FLOAT/active_subs AS cancellation_rate
FROM der.subscription_history
INNER JOIN der.sp_users USING (user_id)
CROSS JOIN dates
WHERE date BETWEEN first_purchased_at::DATE and CURRENT_DATE
AND starting_subscription_duration IN (12) 
-- AND last_country_name != 'United States'
GROUP BY 1,2
ORDER BY 1,2
;