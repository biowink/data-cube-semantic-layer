SELECT  combined_m2_tracking_points AS count_m2_tracking_points,
        COUNT(*) AS count,
        AVG(NVL(m6_to_m12_months_active, 0)::FLOAT) AS mau_retention
FROM temp.retention_metrics
WHERE account_created_at BETWEEN '2022-01-01' AND '2022-09-01'
GROUP BY 1
ORDER BY 1
LIMIT 30
;