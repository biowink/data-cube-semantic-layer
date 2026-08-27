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
            AND CURRENT_DATE - trial_started_at::DATE BETWEEN 14 AND 74
            AND NOT is_in_intro_offer_period
        ),
        trial_sessions AS (
        SELECT subscription_id,
               SUM(CASE WHEN session_id IS NOT NULL THEN 1 ELSE 0 END) AS count_trial_sessions,
               SUM(CASE WHEN life_stage = 'cbc' THEN 1 ELSE 0 END) AS count_trial_cbc_sessions,
               SUM(CASE WHEN life_stage = 'fertility' THEN 1 ELSE 0 END) AS count_trial_cc_sessions,
               SUM(CASE WHEN life_stage = 'pregnant' THEN 1 ELSE 0 END) AS count_trial_pregnancy_sessions
        FROM trials
        LEFT JOIN der.sp_sessions ON trials.master_id = sp_sessions.master_id
          AND sp_sessions.start BETWEEN trial_started_at AND trial_expires_at
        GROUP BY 1
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
          
          CASE WHEN count_trial_cbc_sessions > 0 THEN 'CBC Trial'
          WHEN count_trial_cc_sessions > 0 THEN 'CC Trial'
          WHEN count_trial_pregnancy_sessions > 0 THEN 'Pregnancy Trial'
          ELSE 'Normal Plus Trial'
          END AS trial_type,
          COUNT(*) AS count_trials,
          AVG(CASE WHEN purchases.backend_created_at::DATE - trial_started_at::DATE BETWEEN 0 AND 7 THEN 1::FLOAT ELSE 0 END) * 100 AS trial_conversion_rate
        FROM trials
        LEFT JOIN purchases USING (subscription_id)
        LEFT JOIN trial_sessions USING (subscription_id)
        INNER JOIN der.sp_users ON trials.master_id = sp_users.master_id
        WHERE trial_started_at::DATE = first_seen::DATE
        GROUP BY 1
        ORDER BY 2 DESC
;