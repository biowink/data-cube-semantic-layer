
SELECT
    months_into_lifecycle,
    subscription_source,
    SUM(sample_weight * predicted_renewal_rate) / NULLIF(SUM(sample_weight),0) AS predicted_renewal_rate
FROM der.ltv
WHERE subscription_duration = 12
AND created_execution_date = date '2026-05-01'
GROUP BY 1,2 ORDER BY 1, 2


-- select max(created_execution_date) from models.segmented_ltv