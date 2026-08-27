SELECT
    DATE(DATE_TRUNC('month', created_at)) AS month,
    'new' AS source_version,
    COUNT(*) AS count_records,
    COUNT(DISTINCT device_id) AS count_device_ids,
    COUNT(CASE WHEN device_id_type = 'idfa' THEN user_id END) AS count_idfa_ids,
    COUNT(DISTINCT user_id) AS count_user_ids
FROM airbyte.backend_device_ids
WHERE created_at < CURRENT_DATE
GROUP BY 1, 2
UNION ALL
SELECT
    DATE(DATE_TRUNC('month', created_at)) AS date,
    'old' AS source_version,
    COUNT(*) AS count_records,
    COUNT(DISTINCT device_id) AS count_device_ids,
    COUNT(CASE WHEN device_id_type = 'idfa' THEN user_id END) AS count_idfa_ids,
    COUNT(DISTINCT user_id) AS count_user_ids
FROM import.airbyte_backend_device_ids
WHERE created_at < CURRENT_DATE
GROUP BY 1, 2
ORDER BY 1 DESC, 2
LIMIT 500
;