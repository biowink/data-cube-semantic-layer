    SELECT
        LOWER(platform) AS platform,
        DATE_TRUNC('month', backend_created_at::TIMESTAMP) AS month,
        SUM(CASE WHEN is_in_intro_offer_period THEN 1 ELSE 0 END) AS count_promo_subs,
        SUM(CASE WHEN is_in_intro_offer_period THEN gross_sales_euro ELSE 0 END) AS sum_promo_revenue,
        MEDIAN(CASE WHEN is_in_intro_offer_period THEN ROUND(1-gross_sales_euro/gross_sales_full_price_euro, 2) END) AS discount_rate
    FROM der.subscriptions_events
    WHERE
          backend_created_at BETWEEN '2023-05-01' AND '2024-06-08'
      AND subscription_type = 'Subscription Purchased'
      AND product_id != 'pro.sub.12m.v27.promo3'
      AND LOWER(platform) = 'ios'
    GROUP BY 1, 2
    ORDER BY 1, 2
    ;