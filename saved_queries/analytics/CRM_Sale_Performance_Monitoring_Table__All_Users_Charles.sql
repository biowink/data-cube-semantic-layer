WITH hourly_ios_promos AS (
    SELECT
        LOWER(platform) AS platform,
        DATE_TRUNC('hour', backend_created_at::TIMESTAMP) AS hour,
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
    ),
    running_ios_promos AS (
        SELECT
            platform,
            hour,
            discount_rate,
            count_promo_subs,
            sum_promo_revenue,
            SUM(count_promo_subs)
            OVER (PARTITION BY platform ORDER BY hour ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS running_sum_promos
        FROM hourly_ios_promos
        ),
    lagging_ios_promos AS (
        SELECT
            platform,
            hour,
            discount_rate,
            count_promo_subs,
            sum_promo_revenue,
            running_sum_promos,
            LAG(running_sum_promos) OVER (PARTITION BY platform ORDER BY hour) AS lagged_running_sum_promos
        FROM running_ios_promos
        ),
    ios_sale_partitioning AS (
        SELECT
            platform,
            hour,
            discount_rate,
            count_promo_subs,
            sum_promo_revenue,
            running_sum_promos,
            lagged_running_sum_promos,
            SUM(CASE WHEN running_sum_promos >= 30 AND lagged_running_sum_promos < 30 THEN 1 END)
            OVER (PARTITION BY platform ORDER BY hour ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sale_index
        FROM lagging_ios_promos
        ),
    ios_sales_refactored AS (
        SELECT
            sale_index,
            platform,
            MEDIAN(discount_rate) AS discount_rate,
            MIN(hour) AS starting_hour,
            MAX(hour) AS ending_hour,
            DATEDIFF('hour', starting_hour, ending_hour) AS length_of_sale,
            SUM(count_promo_subs) AS count_promo_subs,
            SUM(sum_promo_revenue) AS count_promo_revenue
        FROM ios_sale_partitioning
        WHERE
            running_sum_promos >= 30
        GROUP BY 1, 2
        HAVING
            length_of_sale > 24
        ),
    ios_sale_metrics AS (
        SELECT
            ios_sales_refactored.platform,
            starting_hour,
            length_of_sale,
            discount_rate,
            SUM(CASE WHEN is_in_intro_offer_period THEN 1 END) AS count_promo_subs,
            SUM(CASE WHEN NOT NVL(is_in_intro_offer_period, FALSE) THEN 1 END) AS count_normal_subs,
            SUM(1) AS count_total_subs,
            SUM(CASE WHEN is_in_intro_offer_period THEN gross_sales_euro END) AS sum_promo_sales,
            SUM(CASE WHEN NOT NVL(is_in_intro_offer_period, FALSE) THEN gross_sales_euro END) AS sum_normal_sales,
            SUM(gross_sales_euro) AS sum_total_sales
        FROM ios_sales_refactored
        INNER JOIN der.subscriptions_events
                   ON DATEDIFF('hour', starting_hour, backend_created_at::TIMESTAMP) BETWEEN -1 AND 24 * 12
                       AND ios_sales_refactored.platform = LOWER(subscriptions_events.platform)
        INNER JOIN der.users USING (analytics_id)
        WHERE
              subscription_type = 'Subscription Purchased'
          AND starting_hour NOT BETWEEN '2023-11-15' AND '2023-12-01'
        GROUP BY 1, 2, 3, 4
        ORDER BY 2
        ),
        hourly_android_promos AS (
    SELECT
        LOWER(platform) AS platform,
        DATE_TRUNC('hour', backend_created_at::TIMESTAMP) AS hour,
        SUM(CASE WHEN is_in_intro_offer_period THEN 1 ELSE 0 END) AS count_promo_subs,
        SUM(CASE WHEN is_in_intro_offer_period THEN gross_sales_euro ELSE 0 END) AS sum_promo_revenue,
        MEDIAN(CASE WHEN is_in_intro_offer_period THEN ROUND(1-gross_sales_euro/gross_sales_full_price_euro, 2) END) AS discount_rate
    FROM der.subscriptions_events
    WHERE
          backend_created_at BETWEEN '2023-05-01' AND '2024-06-08'
      AND subscription_type = 'Subscription Purchased'
      AND product_id != 'pro.sub.12m.v27.promo3'
      AND LOWER(platform) = 'android'
    GROUP BY 1, 2
    ),
    running_android_promos AS (
        SELECT
            platform,
            hour,
            discount_rate,
            count_promo_subs,
            sum_promo_revenue,
            SUM(count_promo_subs)
            OVER (PARTITION BY platform ORDER BY hour ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS running_sum_promos
        FROM hourly_android_promos
        ),
    lagging_android_promos AS (
        SELECT
            platform,
            hour,
            discount_rate,
            count_promo_subs,
            sum_promo_revenue,
            running_sum_promos,
            LAG(running_sum_promos) OVER (PARTITION BY platform ORDER BY hour) AS lagged_running_sum_promos
        FROM running_android_promos
        ),
    android_sale_partitioning AS (
        SELECT
            platform,
            hour,
            discount_rate,
            count_promo_subs,
            sum_promo_revenue,
            running_sum_promos,
            lagged_running_sum_promos,
            SUM(CASE WHEN running_sum_promos >= 15 AND lagged_running_sum_promos < 15 THEN 1 END)
            OVER (PARTITION BY platform ORDER BY hour ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sale_index
        FROM lagging_android_promos
        ),
    android_sales_refactored AS (
        SELECT
            sale_index,
            platform,
            MEDIAN(discount_rate) AS discount_rate,
            MIN(hour) AS starting_hour,
            MAX(hour) AS ending_hour,
            DATEDIFF('hour', starting_hour, ending_hour) AS length_of_sale,
            SUM(count_promo_subs) AS count_promo_subs,
            SUM(sum_promo_revenue) AS count_promo_revenue
        FROM android_sale_partitioning
        WHERE
            running_sum_promos >= 15
        GROUP BY 1, 2
        HAVING
            length_of_sale > 24
        ),
    android_sale_metrics AS (
        SELECT
            android_sales_refactored.platform,
            starting_hour,
            length_of_sale,
            discount_rate,
            SUM(CASE WHEN is_in_intro_offer_period THEN 1 END) AS count_promo_subs,
            SUM(CASE WHEN NOT NVL(is_in_intro_offer_period, FALSE) THEN 1 END) AS count_normal_subs,
            SUM(1) AS count_total_subs,
            SUM(CASE WHEN is_in_intro_offer_period THEN gross_sales_euro END) AS sum_promo_sales,
            SUM(CASE WHEN NOT NVL(is_in_intro_offer_period, FALSE) THEN gross_sales_euro END) AS sum_normal_sales,
            SUM(gross_sales_euro) AS sum_total_sales
        FROM android_sales_refactored
        INNER JOIN der.subscriptions_events
                   ON DATEDIFF('hour', starting_hour, backend_created_at::TIMESTAMP) BETWEEN -1 AND 24 * 12
                       AND android_sales_refactored.platform = LOWER(subscriptions_events.platform)
        INNER JOIN der.users USING (analytics_id)
        WHERE
              subscription_type = 'Subscription Purchased'
          AND starting_hour NOT BETWEEN '2023-11-15' AND '2023-12-01'
        GROUP BY 1, 2, 3, 4
        ORDER BY 2
        )
SELECT *
FROM ios_sale_metrics
UNION
SELECT *
FROM android_sale_metrics
ORDER BY platform, starting_hour
;