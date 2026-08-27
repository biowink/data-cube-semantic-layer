WITH offset_array AS (
    SELECT ROW_NUMBER() OVER (ORDER BY date) AS offset_index
    FROM static.calendar
    LIMIT 7
)
SELECT SPLIT_PART(first_app_version,'.', 1)::INT >= 100 AS is_rebirth,
       offset_index,
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', first_seen, CURRENT_DATE) > offset_index
           THEN sp_users.master_id END) AS count_cohort,
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', first_seen, CURRENT_DATE) > offset_index
           THEN sp_sessions.master_id END) AS count_retained,
       count_retained::FLOAT/count_cohort AS retention_rate
FROM der.sp_users
CROSS JOIN offset_array
LEFT JOIN der.sp_sessions ON sp_users.master_id = sp_sessions.master_id
  AND DATEDIFF('day', first_seen, start) = offset_index AND start < CURRENT_DATE
WHERE first_platform = 'ios' AND first_seen >= '2022-11-15'
GROUP BY 1, 2
ORDER BY 1, 2
;