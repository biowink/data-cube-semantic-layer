SELECT DATE_TRUNC('quarter', month) AS quarter,
       SUM(actual) AS new_users
FROM rep.company_targets_with_actuals
WHERE segment = 'Global' AND metric = 'New Users'
  AND month < DATE('2024-10-01')
  AND month >= DATE('2021-01-01')
GROUP BY 1
ORDER BY 1
;