WITH retention_offsets AS (
    SELECT ROW_NUMBER() OVER() - 1 AS subscription_year,
           subscription_year * 365 + 7 AS offset_days
    FROM import.subscriptions
    LIMIT 6
)
SELECT DATE_TRUNC('quarter', started_at::DATE) AS quarter,
       subscription_year,
       COUNT(DISTINCT id) AS cohort_size,
       COUNT(DISTINCT CASE WHEN started_at::DATE + offset_days < expires_at::DATE
                            AND started_at::DATE + offset_days < CURRENT_DATE THEN id END)::FLOAT/
         NULLIF(COUNT(DISTINCT CASE WHEN started_at::DATE + offset_days < CURRENT_DATE THEN id END), 0) AS retention_rate
FROM import.subscriptions
CROSS JOIN retention_offsets
WHERE NOT is_trial_period
  AND REPLACE(SPLIT_PART(product_id, '.', 3), 'm','')::INT = 12
  AND DATEDIFF('day', started_at::DATE, expires_at::DATE) >= 180
GROUP BY 1, 2
HAVING retention_rate IS NOT NULL
ORDER BY 1 DESC, 2
;