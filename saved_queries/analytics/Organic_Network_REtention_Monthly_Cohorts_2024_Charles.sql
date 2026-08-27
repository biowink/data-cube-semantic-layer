SELECT account_created_month,
       "month",
       DATE_DIFF('month', account_created_month, "month") AS months_into_lifecyle,
       network,
       SUM(cohort_size) AS total_cohort_size,
       SUM(net_mau) AS total_net_mau,
       SUM(net_mau) * 1.0/SUM(cohort_size) AS retention_rate
FROM rep.monthly_active_user_growth
WHERE account_created_month >= DATE('2024-01-01') AND network IS NOT NULL AND cohort_size > 1000
  AND DATE_DIFF('month', account_created_month, "month") >= 0
  AND network = 'Organic'
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4
;