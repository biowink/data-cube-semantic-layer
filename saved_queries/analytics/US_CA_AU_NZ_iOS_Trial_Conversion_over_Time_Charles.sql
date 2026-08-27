        WITH
        trials AS (
          SELECT
            backend_created_at,
            started_at AS trial_started_at,
            expires_at AS trial_expires_at,
            platform,
            country,
            subscription_id,
            transaction_id,
            product_id,
            master_id,
            analytics_id
          FROM
            der.subscriptions_events
          WHERE
            subscription_type = 'Subscription Free Trial'
            AND subscription_duration = 12
            AND trial_started_at::DATE >= '2022-01-01'
        ),
        purchases AS (
          SELECT
            backend_created_at,
            platform,
            country,
            subscription_id,
            transaction_id,
            product_id,
            master_id,
            analytics_id,
            gross_sales_euro
          FROM
            der.subscriptions_events
          WHERE
            subscription_type = 'Subscription Purchased'
            AND subscription_duration = 12
            AND NOT is_in_intro_offer_period
        )
      SELECT
          
          DATE_TRUNC('month', trial_started_at),
          AVG(CASE WHEN purchases.backend_created_at::DATE - trial_started_at::DATE BETWEEN 0 AND 7 THEN 1::FLOAT ELSE 0 END) AS trial_conversion_rate
        FROM
        trials
        LEFT JOIN purchases USING (subscription_id)
        WHERE trials.platform = 'IOS' AND NVL(trials.country, purchases.country) IN ('United States', 'New Zealand', 'Australia', 'Canada')
         AND CURRENT_DATE - trial_started_at::DATE >= 8
        GROUP BY 1
        ORDER BY 1 DESC
;