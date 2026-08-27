SELECT first_seen::DATE AS first_seen_dt,
       COUNT(*) AS count_users_without_analytics_id
FROM der.sp_users
WHERE first_platform = 'ios' AND first_seen >= '2023-01-01' AND analytics_id IS NULL
GROUP BY 1
ORDER BY 1 DESC
;