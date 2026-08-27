SELECT date,
       COUNT(*)
FROM der.clue_plus_user_lifetimes
INNER JOIN der.sp_users USING (master_id)
WHERE SPLIT_PART(CASE WHEN last_app_version LIKE '%u%' THEN NULL ELSE last_app_version END,'.', 1)::INT >= 101 
  AND mode = 'conceive' 
  AND had_positive_pregnancy_test
  AND date >= '2022-07-01'
GROUP BY 1
ORDER BY 1
;