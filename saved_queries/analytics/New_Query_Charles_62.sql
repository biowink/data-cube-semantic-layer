SELECT first_seen::DATE,
       first_platform,
--        SPLIT_PART(first_app_version, '.', 1)::INT AS major_version,
       COUNT(*) AS count_new_users,
       COUNT(CASE WHEN account_is_verified THEN master_id END) AS count_verified,
       count_verified::FLOAT/NULLIF(count_new_users,0)
FROM der.sp_users
WHERE first_seen >= '2022-12-01' 
--   AND SPLIT_PART(first_app_version, '.', 1)::INT IN (73, 101)
GROUP BY 1, 2
ORDER BY 1, 2
;