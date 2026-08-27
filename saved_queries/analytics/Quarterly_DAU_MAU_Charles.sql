SELECT DATE_TRUNC('quarter', month) AS quarter,
       (SUM(total_days_active) * 100.0/SUM(net_mau))/30 AS dau_mau
FROM rep.monthly_active_user_growth
WHERE month < DATE('2024-10-01')
  AND month >= DATE('2022-01-01')
GROUP BY 1
ORDER BY 1
;