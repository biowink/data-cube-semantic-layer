SELECT DATE_TRUNC('week', first_seen::DATE) AS week,
       SPLIT_PART(first_app_version, '.', 1)::INT > 100 AS is_rebirth,
       COUNT(DISTINCT master_id) AS cohort_count,
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', first_seen, session_start) = 1 THEN master_id END) AS d1_retention,
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', first_seen, session_start) = 2 THEN master_id END) AS d2_retention,
       d1_retention::FLOAT/cohort_count AS d1_retention_rate,
       d2_retention::FLOAT/cohort_count AS d2_retention_rate
FROM der.sp_users
LEFT JOIN der.sessions USING (master_id)
WHERE first_seen BETWEEN '2023-02-01' AND CURRENT_DATE - 3 
  AND first_platform = 'android' 
  AND NOT is_test_user 
  AND sp_users.analytics_id IS NOT NULL
GROUP BY 1, 2
HAVING cohort_count > 100
ORDER BY 1, 2
;