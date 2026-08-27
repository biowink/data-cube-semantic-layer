SELECT DATE_TRUNC('month', backend_created_at) AS month,
       subscription_duration,
       COUNT(*) AS count,
       SUM(gross_sales_euro) AS total_gross_sales_euro,
       AVG(gross_sales_euro) AS avg_gross_sales_euro,
       SUM(sales_without_tax_euro) AS total_sales_without_tax_euro,
       AVG(sales_without_tax_euro) AS avg_sales_without_tax_euro,
       SUM(tax_euro) AS total_tax_euro,
       AVG(tax_euro) AS avg_tax_euro,
       AVG(tax_rate) AS avg_tax_rate
FROM der.subscriptions_events
WHERE subscription_type = 'Subscription Purchased' 
    AND subscription_duration IN (1, 12)
    AND backend_created_at < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY 1, 2
ORDER BY 1 DESC, 2
;