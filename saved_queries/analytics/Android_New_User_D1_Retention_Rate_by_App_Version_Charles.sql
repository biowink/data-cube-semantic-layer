SELECT first_app_version,
       COUNT(DISTINCT sp_users.master_id) AS count_new_users,
       COUNT(DISTINCT sessions.master_id) AS count_d1_retained,
       count_d1_retained::FLOAT/count_new_users AS d1_retention_Rate
FROM der.sp_users
LEFT JOIN der.sessions ON sp_users.master_id = sessions.master_id
            AND DATEDIFF('day', first_seen, session_start) = 1 AND session_start >= '2023-04-01'
WHERE first_seen::DATE BETWEEN '2023-04-01' AND CURRENT_DATE - 2
    AND first_platform = 'android'
GROUP BY 1
HAVING count_new_users > 2000
ORDER BY 1
;