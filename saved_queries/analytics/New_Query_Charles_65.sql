SELECT backend_tracking.backend_updated_at::DATE,
       COUNT(DISTINCT master_id) AS user_count
FROM der.sp_users 
INNER JOIN der.backend_tracking USING (master_id)
WHERE SPLIT_PART(CASE WHEN last_app_version LIKE '%u%' THEN NULL ELSE last_app_version END,'.', 1)::INT >= 101
  AND backend_tracking.backend_updated_at >= '2022-12-01' 
  AND category = 'exercise'
  AND revision_type = 'measurements_tracked'
GROUP BY 1
ORDER BY 1
;