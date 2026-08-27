WITH promotion_sale_dates AS (
    SELECT
        date AS promotion_start_date
    FROM static.calendar
    WHERE
            date IN ('2021-07-03',
                     '2021-07-24',
                     '2021-09-25',
                     '2021-11-26',
                     '2021-12-26',
                     '2022-01-08',
                     '2022-02-14',
                     '2022-04-30',
                     '2022-05-09',
                     '2022-06-27',
                     '2022-10-09',
                     '2022-11-25',
                     '2023-01-06')
)
SELECT promotion_start_date,
       SUM(CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND -3
           THEN gross_sales_euro END)::FLOAT/
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND -3
           THEN backend_created_at::DATE END) AS avg_daily_purchase_sales_presale,
       SUM(CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -1 AND 12
           THEN gross_sales_euro END)::FLOAT/
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -1 AND 12
           THEN backend_created_at::DATE END) AS avg_daily_purchase_sales_postsale,
    (avg_daily_purchase_sales_postsale::FLOAT/avg_daily_purchase_sales_presale - 1) * 14 AS net_purchase_sales_uplift_in_days,
       net_purchase_sales_uplift_in_days * avg_daily_purchase_sales_presale AS total_purchase_sales_gain,
       SUM(CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND -3
           AND subscription_duration = 1
           THEN 1 END)::FLOAT/
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND -3
           THEN backend_created_at::DATE END) AS avg_daily_1m_new_subs_presale,
       SUM(CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -1 AND 12
           AND subscription_duration = 1
           THEN 1 END)::FLOAT/
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -1 AND 12
           THEN backend_created_at::DATE END) AS avg_daily_1m_new_subs_postsale,
    (avg_daily_1m_new_subs_postsale::FLOAT/avg_daily_1m_new_subs_presale - 1) AS new_1m_sub_uplift,
       SUM(CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND -3
           AND subscription_duration = 12
           THEN 1 END)::FLOAT/
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND -3
           THEN backend_created_at::DATE END) AS avg_daily_12m_new_subs_presale,
       SUM(CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -1 AND 12
           AND subscription_duration = 12
           THEN 1 END)::FLOAT/
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -1 AND 12
           THEN backend_created_at::DATE END) AS avg_daily_12m_new_subs_postsale,
    (avg_daily_12m_new_subs_postsale::FLOAT/avg_daily_12m_new_subs_presale - 1) * 14 AS new_12m_sub_uplift_in_days,
    new_12m_sub_uplift_in_days * avg_daily_12m_new_subs_presale AS total_12m_subscriber_gain
FROM promotion_sale_dates
LEFT JOIN der.subscriptions_events ON DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND 12
                                        AND subscription_type IN ('Subscription Purchased')
--                                         AND platform = 'IOS' -- For calculating the metrics for the platform-specific promotions
LEFT JOIN der.sp_users USING (master_id)
LEFT JOIN static.market_mapping ON subscriptions_events.country = market_mapping.country
GROUP BY 1
ORDER BY 1
;