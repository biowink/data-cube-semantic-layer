SELECT DATE_TRUNC('week', first_purchased_at) AS week,
       platform,
       COUNT(DISTINCT first_purchased_at::DATE) AS days_in_week,
       COUNT(*) AS count_subs,
       AVG(CASE WHEN last_canceled_at::DATE - first_purchased_at::DATE <= 7 THEN 1::FLOAT ELSE 0 END) AS cancellation
FROM der.subscription_history
WHERE is_purchased AND NOT is_partner_subscription AND CURRENT_DATE - first_purchased_at::DATE > 7
  AND first_purchased_at >= '2023-05-01'
GROUP BY 1, 2
HAVING days_in_week = 7
ORDER BY 1 DESC, 2
;