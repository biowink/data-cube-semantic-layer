with total as (
SELECT 
    count(subscription_id) as total_subscriptions
FROM der.subscriptions_events
WHERE subscription_type = 'Subscription Purchased'
    AND platform = 'IOS'
    AND subscription_duration = 12
    AND backend_created_at between '2022-08-01' and '2022-09-01'
)

SELECT 
    case when country in ('Austria', 'Belgium', 'Denmark', 'France',
          'Germany', 'Ireland', 'Luxembourg', 'Netherlands',
          'Norway', 'Sweden', 'Switzerland', 'United Kingdom', 'Italy', 'Spain',
          'Australia', 'Canada', 'Japan', 'New Zealand') then 'strategic'
         when country = 'United States' then 'states'
         else 'other'
         end as market,
    count(subscription_id)::float / total_subscriptions as share_of_subscriptions,
    AVG(CASE WHEN is_in_intro_offer_period is FALSE then gross_sales_euro else null end) AS avg_full_gross_price,
    AVG(CASE WHEN is_in_intro_offer_period is TRUE then gross_sales_euro else null end) AS avg_promo_gross_price,
    AVG(CASE WHEN is_in_intro_offer_period is FALSE then net_sales_euro else null end) AS avg_full_net_price,
    AVG(CASE WHEN is_in_intro_offer_period is TRUE then net_sales_euro else null end) AS avg_promo_net_price,
    COUNT(CASE WHEN is_in_intro_offer_period is FALSE then 1 else null end) AS full_price_conversion_count,
    COUNT(CASE WHEN is_in_intro_offer_period is TRUE then 1 else null end) AS promo_conversion_count,
    AVG(CASE WHEN is_in_intro_offer_period is FALSE then tax_rate else null end) AS avg_full_tax_rate,
    AVG(CASE WHEN is_in_intro_offer_period is TRUE then tax_rate else null end) AS avg_promo_tax_rate
FROM der.subscriptions_events
JOIN total on 1=1
WHERE subscription_type = 'Subscription Purchased'
    AND platform = 'IOS'
    -- AND country = 'United States'
    -- AND country in ('Austria', 'Belgium', 'Denmark', 'France',
    --       'Germany', 'Ireland', 'Luxembourg', 'Netherlands',
    --       'Norway', 'Sweden', 'Switzerland', 'United Kingdom', 'Italy', 'Spain',
    --       'Australia', 'Canada', 'Japan', 'New Zealand')
    AND subscription_duration = 12
    AND backend_created_at between '2022-08-01' and '2022-09-01'
GROUP BY 1, total_subscriptions
ORDER BY 1

