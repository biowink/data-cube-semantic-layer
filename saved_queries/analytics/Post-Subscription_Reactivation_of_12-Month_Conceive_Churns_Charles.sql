SELECT afterchurn.mode, COUNT(*)
FROM der.subscription_history
INNER JOIN der.clue_plus_user_lifetimes beforechurn USING (analytics_id)
INNER JOIN der.clue_plus_user_lifetimes afterchurn USING (analytics_id)
WHERE is_expired AND is_purchased AND subscription_history.platform = 'IOS'
AND DATEDIFF('day', beforechurn.date, expires_at::DATE) = 1
AND DATEDIFF('day', afterchurn.date, expires_at::DATE) = -90
AND expires_at::DATE BETWEEN '2023-04-01' AND '2023-06-30'
AND beforechurn.mode IN ('conceive', 'period tracking', 'pregnancy')
AND subscription_history.subscription_duration = 12
AND afterchurn.is_paid_subscribed
AND NOT is_fully_refunded
GROUP BY 1
ORDER BY 1