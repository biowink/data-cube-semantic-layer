SELECT DATE_TRUNC('month', user_first_converted_at::DATE) AS cohort_month,
       FLOOR(DATEDIFF('day', user_first_converted_at::DATE, date)/30) AS month_into_lifecycle,
       COUNT(DISTINCT analytics_id) AS cohort_size,
       COUNT(DISTINCT CASE WHEN sum_exit_data_entry > 0 THEN analytics_id END) AS tracking_retained_users,
       COUNT(DISTINCT CASE WHEN MOD(DATEDIFF('day', user_first_converted_at::DATE, date), 30) = 29 
                                    AND is_paid_subscribed THEN analytics_id END) AS subscription_retained_users,
       tracking_retained_users::FLOAT/cohort_size AS tracking_retention_rate,
       subscription_retained_users::FLOAT/cohort_size AS subscription_retention_rate
FROM der.clue_plus_user_lifetimes
INNER JOIN der.subscription_history USING (analytics_id)
WHERE subscription_history.user_converted_with_this_subscription
  AND cohort_month >= '2022-01-01'
  AND DATEDIFF('day', user_first_converted_at::DATE, date) >= 0
  AND DATEDIFF('day', date, CURRENT_DATE) >= 30
GROUP BY 1, 2
ORDER BY 1, 2
;