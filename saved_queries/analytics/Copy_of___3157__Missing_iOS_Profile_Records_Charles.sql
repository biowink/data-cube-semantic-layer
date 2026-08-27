SELECT DATE(account_created_at) AS date,
    platform,
    COUNT(users.analytics_id) AS count_user_records,
    COUNT(profiles.analytics_id) AS count_profile_records
FROM der.users
LEFT JOIN der.profiles ON users.analytics_id = profiles.analytics_id
LEFT JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
WHERE platform IS NOT NULL AND account_created_at >= DATE('2024-10-01')
GROUP BY 1, 2
ORDER BY 2, 1
;