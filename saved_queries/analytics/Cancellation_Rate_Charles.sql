SELECT date,
       COUNT(DISTINCT CASE WHEN date BETWEEN first_purchased_at AND expires_at THEN analytics_id END) AS paying_users,
       COUNT(DISTINCT CASE WHEN date BETWEEN last_canceled_at AND expires_at THEN analytics_id END) AS canceled_users,
       canceled_users::FLOAT/paying_users AS share_on_canceled_subs
FROM static.calendar
CROSS JOIN der.subscription_history
WHERE (calendar.date = CURRENT_DATE - 1 OR calendar.day_is_first_of_month) 
AND calendar.date BETWEEN '2021-01-01' AND CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC
;