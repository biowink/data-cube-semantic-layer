SELECT platform,
       DATE_TRUNC('month', account_created_at) AS account_created_month,
       AVG(CASE WHEN birthday IS NULL THEN 1.0 ELSE 0 END) AS share_users_missing_birthday
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
LEFT JOIN der.profiles USING (analytics_id)
WHERE platform IS NOT NULL AND account_created_at >= DATE('2022-01-01')
GROUP BY 1, 2
ORDER BY 1, 2