WITH free_trials AS (
    SELECT
        se.master_id,
        first_app_version,
        subscription_id,
        backend_created_at as free_trial_at
        
    FROM der.subscriptions_events se
    JOIN der.sp_users u
      ON (se.master_id = u.master_id
          AND se.backend_created_at::date = u.first_seen::date)
    WHERE backend_created_at <= CURRENT_DATE - '7 days'::interval
      AND subscription_type = 'Subscription Free Trial'
      AND se.platform = 'IOS'
      AND first_app_version BETWEEN 50.0 AND 65.0
      AND first_app_version != 59.0
),

conversions AS (
    SELECT
        se.master_id,
        subscription_id,
        backend_created_at as purchase_at
        
    FROM der.subscriptions_events se
    WHERE subscription_type = 'Subscription Purchased'
      AND platform = 'IOS'
)

SELECT
    first_app_version,
    COUNT(ft.master_id) as free_trials,
    COUNT(c.master_id) as conversions,
    conversions::float / free_trials as free_trial_conversion_rate


FROM free_trials ft
LEFT JOIN conversions c 
    ON (ft.master_id = c.master_id
        AND ft.subscription_id = c.subscription_id
        AND purchase_at BETWEEN free_trial_at AND free_trial_at + '8 days'::interval)
GROUP BY 1
ORDER BY 1
