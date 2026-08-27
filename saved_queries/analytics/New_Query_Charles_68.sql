SELECT date,
       COUNT(DISTINCT master_id) AS user_count
FROM der.sp_users 
INNER JOIN der.backend_tracking USING (master_id)
WHERE SPLIT_PART(CASE WHEN last_app_version LIKE '%u%' THEN NULL ELSE last_app_version END,'.', 1)::INT >= 101
  AND date >= '2022-07-01' AND category = 'tests' AND type = 'pregnancy_positive'
GROUP BY 1
ORDER BY 1
;