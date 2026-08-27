with gross_sales AS (
    SELECT
        DATE_TRUNC('month', all_subscriptions_events.backend_created_at) as dt,
        SUM(CASE WHEN adjust_attribution.network IN ('Google Ads ACI', 'Apple Search Ads', 'TikTok', 'Facebook')
         THEN gross_sales_euro ELSE NULL END) as paid_gross_sales_euro,
        SUM(CASE WHEN adjust_attribution.network NOT IN ('Google Ads ACI', 'Apple Search Ads', 'TikTok', 'Facebook')
         THEN gross_sales_euro ELSE NULL END) as organic_gross_sales_euro
    FROM der.all_subscriptions_events
    JOIN der.users USING(analytics_id)
    JOIN user_metrics.adjust_attribution USING (analytics_id)
    WHERE all_subscriptions_events.subscription_type IN (
      'Subscription Purchased',
      'Subscription Renewed',
      'Subscription Payable Action',
      'Subscription Refunded'
      )
    AND all_subscriptions_events.backend_created_at BETWEEN DATE '2025-01-01' and DATE '2025-12-01'
    AND DATE_DIFF('day', users.account_created_at, all_subscriptions_events.backend_created_at) <= 30
    GROUP BY 1
),

ad_spend AS (
    SELECT
        DATE_TRUNC('month', date) as dt,
        SUM(cost) as ad_spend
    FROM der.adjust_campaign_performance
    WHERE date BETWEEN DATE '2025-01-01' and DATE '2025-12-01'
    and network != 'TikTok Brand'
    GROUP BY 1
)

SELECT *
FROM gross_sales
JOIN ad_spend USING(dt)
where dt < date '2025-12-01'
ORDER BY dt
