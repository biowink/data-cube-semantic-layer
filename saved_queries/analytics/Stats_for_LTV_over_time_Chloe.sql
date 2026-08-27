SELECT 
    DATE_TRUNC('month', backend_created_at) as month,
    AVG(CASE WHEN is_in_intro_offer_period is FALSE then gross_sales_euro else null end) AS avg_full_gross_price,
    AVG(CASE WHEN is_in_intro_offer_period is TRUE then gross_sales_euro else null end) AS avg_promo_gross_price,
    AVG(CASE WHEN is_in_intro_offer_period is FALSE then net_sales_euro else null end) AS avg_full_net_price,
    AVG(CASE WHEN is_in_intro_offer_period is TRUE then net_sales_euro else null end) AS avg_promo_net_price,
    COUNT(CASE WHEN is_in_intro_offer_period is FALSE then 1 else null end) AS full_price_conversion_count,
    COUNT(CASE WHEN is_in_intro_offer_period is TRUE then 1 else null end) AS promo_conversion_count,
    AVG(CASE WHEN is_in_intro_offer_period is FALSE then tax_rate else null end) AS avg_full_tax_rate,
    AVG(CASE WHEN is_in_intro_offer_period is TRUE then tax_rate else null end) AS avg_promo_tax_rate
FROM der.subscriptions_events
WHERE subscription_type = 'Subscription Purchased'
    AND platform = 'IOS'
    -- AND country = 'United States'
    AND country in ('Austria', 'Belgium', 'Denmark', 'France',
          'Germany', 'Ireland', 'Luxembourg', 'Netherlands',
          'Norway', 'Sweden', 'Switzerland', 'United Kingdom', 'Italy', 'Spain',
          'Australia', 'Canada', 'Japan', 'New Zealand')
    AND subscription_duration = 12
    AND backend_created_at >= '2021-07-01'
GROUP BY month
ORDER BY month


