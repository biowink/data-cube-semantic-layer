SELECT first_platform,
       first_seen::DATE AS date,
       COUNT(*) AS count,
       AVG(CASE WHEN account_is_verified THEN 1::FLOAT ELSE 0 END) AS share_verified
FROM der.sp_users
WHERE first_seen >= '2022-11-01' AND first_platform IN ('ios', 'android')
GROUP BY 1, 2
ORDER BY 1, 2
;