SELECT country = 'United States' AS is_us_market,
       started_in_intro_offer_period,
       date - first_purchased_at::DATE AS days_into_sub,
       AVG(CASE WHEN last_canceled_at::DATE <= date THEN 1::FLOAT ELSE 0 END) AS running_cancellation_rate
FROM der.subscription_history
CROSS JOIN static.calendar
WHERE starting_subscription_duration = 12 AND first_purchased_at >= '2021-01-01'
  AND date - first_purchased_at::DATE BETWEEN 0 AND 365
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;