SELECT SUM(gross_sales_euro) AS actual_revenue,
       SUM(gross_sales_euro * COALESCE(unit_value, 1)) AS revenue_under_new_model,
       SUM(gross_sales_euro * COALESCE(unit_value, 1)) - SUM(gross_sales_euro) AS difference_absolute,
       1 - SUM(gross_sales_euro * COALESCE(unit_value, 1))/SUM(gross_sales_euro) AS difference_relative
FROM der.all_subscriptions_events
LEFT JOIN static.partner_contracts ON partner_contracts.partner = 'gympass' AND all_subscriptions_events.country = partner_contracts.country
    AND start_date = DATE '2025-08-01'
WHERE backend_created_at >= DATE '2025-07-01' AND backend_created_at < DATE '2025-08-01'
    AND all_subscriptions_events.partner = 'gympass'
    AND is_financial_transaction
;