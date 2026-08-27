SELECT backend_created_at::DATE AS date,
       COUNT(*) AS count,
       AVG(CASE WHEN email_is_verified THEN 1::FLOAT ELSE 0 END) AS share_verified
FROM import.users
WHERE date >= '2022-11-01'
GROUP BY 1
ORDER BY 1 DESC;