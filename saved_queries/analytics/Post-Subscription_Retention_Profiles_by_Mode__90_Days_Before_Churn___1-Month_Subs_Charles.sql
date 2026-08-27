SELECT beforechurn.mode,
       DATEDIFF('day', expires_at::DATE, lifetime.date) AS days_to_expiry,
       COUNT(lifetime.is_dau) AS count_users,
       AVG(CASE WHEN lifetime.is_dau THEN 1::FLOAT WHEN NOT lifetime.is_dau THEN 0 END) AS share_dau,
       AVG(CASE WHEN lifetime.is_wau THEN 1::FLOAT WHEN NOT lifetime.is_wau THEN 0 END) AS share_wau,
       AVG(CASE WHEN lifetime.is_mau THEN 1::FLOAT WHEN NOT lifetime.is_mau THEN 0 END) AS share_mau,
       AVG(CASE WHEN lifetime.is_paid_subscribed THEN 1::FLOAT WHEN NOT lifetime.is_paid_subscribed THEN 0 END) AS share_paid
FROM der.subscription_history
INNER JOIN der.clue_plus_user_lifetimes beforechurn USING (analytics_id)
INNER JOIN der.clue_plus_user_lifetimes lifetime USING (analytics_id)
WHERE is_expired AND is_purchased AND subscription_history.platform = 'IOS'
AND DATEDIFF('day', beforechurn.date, expires_at::DATE) = 90
AND DATEDIFF('day', expires_at::DATE, lifetime.date) BETWEEN -90 AND 90
AND expires_at::DATE BETWEEN '2023-04-01' AND '2023-06-30'
AND beforechurn.mode IN ('conceive', 'period tracking', 'pregnancy')
AND subscription_history.subscription_duration = 1
AND NOT is_fully_refunded
GROUP BY 1, 2
ORDER BY 1, 2
;