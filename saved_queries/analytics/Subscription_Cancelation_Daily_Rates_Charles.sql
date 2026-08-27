WITH dates AS (
    SELECT DISTINCT started_at::DATE AS date FROM der.subscription_history WHERE started_at > '2022-01-01'
)
SELECT DATE_TRUNC('week',date) AS week,
        starting_subscription_duration,
       SUM(1) AS active_subs,
       SUM(CASE WHEN date < NVL(subscription_history.last_canceled_at::DATE, '9999-01-01') THEN 1 END) AS uncanceled_subs,
       SUM(CASE WHEN last_canceled_at::DATE = date THEN 1 END) AS cancelations,
       cancelations::FLOAT/uncanceled_subs AS daily_cancelation_rate
FROM der.subscription_history
INNER JOIN der.sp_users USING (user_id)
CROSS JOIN dates
WHERE date BETWEEN first_purchased_at::DATE and expires_at::DATE 
AND starting_subscription_duration IN (1, 12) 
-- AND last_country_name != 'United States'
GROUP BY 1,2
ORDER BY 1,2
;