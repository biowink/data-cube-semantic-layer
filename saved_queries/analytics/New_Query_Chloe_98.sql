SELECT
    start,
    master_id,
    sp_device_id,
    user_id,
    analytics_id
FROM der.sp_sessions 
WHERE master_id in (16721248, 28319707)
  AND start >= '2022-06-01'
ORDER BY start;