SELECT date,
       COUNT(DISTINCT master_id) AS user_count
FROM der.sp_users
INNER JOIN der.tracking USING (master_id)
WHERE date >= '2022-07-01'
  AND category = 'test'
  AND type = 'pregnancy_test_pos'
    AND last_platform = 'android'
GROUP BY 1
ORDER BY 1
;

