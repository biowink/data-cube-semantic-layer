SELECT
    platform,
    customer_currency,
    product_id,
    COUNT(*) AS count,
    SUM(gross_sales_euro) AS total_sales,
    AVG(gross_sales_full_price_euro) AS avg_price
FROM der.subscriptions_events
WHERE
    product_id = 'pro.sub.12m.v25.promo75'
    AND backend_created_at >= CURRENT_DATE - 3
    AND country IN ('United States', 'Germany')
    AND subscription_type = 'Subscription Purchased'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
;