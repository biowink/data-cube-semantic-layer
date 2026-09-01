WITH user_first_subscription AS (
    SELECT 
        analytics_id, 
        MIN(backend_created_at) AS first_sub_at
    FROM der.all_subscriptions_events
    WHERE subscription_type in ('Subscription Purchased', 'Subscription Free Trial', 'Subscription Paddle Trial', 'Subscription Granted')
    GROUP BY 1
),
daily_converters AS (
    -- Identify users who subbed within 24 hours of joining
    SELECT 
        u.analytics_id,
        u.account_created_at,
        case when s.account_source in ('iOS', 'Android') then 'app' 
             when s.account_source is null or s.account_source in ('Web', 'web') then 'web'
             else null end as account_source
    FROM der.users u
    JOIN user_first_subscription sub ON u.analytics_id = sub.analytics_id
    LEFT JOIN user_metrics.user_account_source s ON u.analytics_id = s.analytics_id
    WHERE date_diff('day', u.account_created_at, sub.first_sub_at) = 0
    and u.account_created_at >= date '2026-01-01'
    and s.account_source != 'Missing'
)
SELECT 
    date_trunc('week', account_created_at) AS registration_week,
    account_source,
    COUNT(analytics_id) AS same_day_subscriber_count
FROM daily_converters
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;
