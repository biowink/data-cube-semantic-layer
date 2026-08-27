WITH hourly_ios_promos AS (
    SELECT
        LOWER(platform) AS platform,
        DATE_TRUNC('hour', backend_created_at::TIMESTAMP) AS hour,
        SUM(CASE WHEN is_in_intro_offer_period THEN 1 ELSE 0 END) AS count_promo_subs,
        SUM(CASE WHEN is_in_intro_offer_period THEN gross_sales_euro ELSE 0 END) AS sum_promo_revenue,
        MEDIAN(CASE WHEN is_in_intro_offer_period THEN ROUND(1-gross_sales_euro/gross_sales_full_price_euro, 2) END) AS discount_rate
    FROM der.subscriptions_events
    WHERE
          backend_created_at BETWEEN '2023-05-01' AND CURRENT_DATE
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
        hourly_android_promos AS (
    SELECT
        LOWER(platform) AS platform,
        DATE_TRUNC('hour', backend_created_at::TIMESTAMP) AS hour,
        SUM(CASE WHEN is_in_intro_offer_period THEN 1 ELSE 0 END) AS count_promo_subs,
        SUM(CASE WHEN is_in_intro_offer_period THEN gross_sales_euro ELSE 0 END) AS sum_promo_revenue,
        MEDIAN(CASE WHEN is_in_intro_offer_period THEN ROUND(1-gross_sales_euro/gross_sales_full_price_euro, 2) END) AS discount_rate
    FROM der.subscriptions_events
    WHERE
          backend_created_at BETWEEN '2023-05-01' AND CURRENT_DATE
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
        )
SELECT ios_sales_refactored.platform,
       starting_hour,
       ending_hour,
       length_of_sale,
       COUNT(DISTINCT analytics_id) AS count_active_users,
       COUNT(DISTINCT CASE WHEN subscription_started_transaction_id IS NOT NULL THEN analytics_id END) AS count_conversions,
       count_conversions::FLOAT/count_active_users AS existing_user_conversion_rate
FROM ios_sales_refactored
INNER JOIN der.sessions ON session_start BETWEEN starting_hour AND ending_hour AND sessions.platform = 'ios'
INNER JOIN der.users USING (analytics_id)
WHERE session_start::DATE > account_created_at::DATE + 30
GROUP BY 1, 2, 3, 4
UNION ALL
SELECT android_sales_refactored.platform,
       starting_hour,
       ending_hour,
       length_of_sale,
       COUNT(DISTINCT analytics_id) AS count_active_users,
       COUNT(DISTINCT CASE WHEN subscription_started_transaction_id IS NOT NULL THEN analytics_id END) AS count_conversions,
       count_conversions::FLOAT/count_active_users AS existing_user_conversion_rate
FROM android_sales_refactored
INNER JOIN der.sessions ON session_start BETWEEN starting_hour AND ending_hour AND sessions.platform = 'android'
INNER JOIN der.users USING (analytics_id)
WHERE session_start::DATE > account_created_at::DATE + 30
GROUP BY 1, 2, 3, 4
ORDER BY platform, starting_hour
;
