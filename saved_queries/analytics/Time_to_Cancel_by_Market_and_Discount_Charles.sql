SELECT started_in_intro_offer_period,
       date - first_purchased_at::DATE AS days_into_sub,
       AVG(CASE WHEN last_canceled_at::DATE <= date THEN 1::FLOAT ELSE 0 END) AS running_cancellation_rate
FROM der.subscription_history
INNER JOIN intermediate.market_mapping USING (country)
CROSS JOIN static.calendar
WHERE starting_subscription_duration = 12 
  AND first_purchased_at BETWEEN '2021-06-01' AND '2021-10-01'
  AND date - first_purchased_at::DATE BETWEEN 0 AND 365 
  AND date < CURRENT_DATE
--   AND first_purchased_at::DATE = started_at::DATE
--   AND market = 'US'
--   AND market = 'Strategic Europe'
--   AND market = 'Strategic w/o US and Europe'
--   AND market LIKE '%Strategic%'
--   AND market = 'Rest of World'
  AND platform = 'IOS'
GROUP BY 1, 2
ORDER BY 1, 2
;
