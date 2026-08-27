SELECT backend_created_at::DATE AS date,
       first_platform,
       COUNT(*) AS count,
       AVG(CASE WHEN email_is_verified THEN 1::FLOAT ELSE 0 END) AS share_verified
FROM import.users
INNER JOIN der.sp_users USING (analytics_id)
WHERE date >= '2022-09-01' AND first_platform IS NOT NULL
GROUP BY 1, 2
ORDER BY 2, 1 DESC
;