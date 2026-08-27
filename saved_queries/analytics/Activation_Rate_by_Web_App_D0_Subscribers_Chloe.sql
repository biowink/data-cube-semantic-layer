WITH user_first_subscription AS (
    SELECT 
        analytics_id, 
        coalesce(all_subscriptions_events.partner, google_sheets_discount_code_metadata.partner) as partner,
        backend_created_at,
        ROW_NUMBER() OVER (PARTITION BY analytics_id ORDER BY backend_created_at ASC) as event_rank
    FROM der.all_subscriptions_events
    LEFT JOIN airbyte.google_sheets_discount_code_metadata on (all_subscriptions_events.code = google_sheets_discount_code_metadata.code)
    WHERE subscription_type in ('Subscription Purchased', 'Subscription Free Trial', 'Subscription Paddle Trial', 'Subscription Granted')
),
daily_converters AS (
    -- Identify users who subbed within 24 hours of joining
    SELECT 
        u.analytics_id,
        u.account_created_at,
        case when s.account_source in ('iOS', 'Android') then 'app' 
             when s.account_source is null or s.account_source in ('Web', 'web') then 'web'
             else null end as account_source,
        partner
    FROM der.users u
    JOIN user_first_subscription sub ON u.analytics_id = sub.analytics_id
    LEFT JOIN user_metrics.user_account_source s ON u.analytics_id = s.analytics_id
    WHERE sub.event_rank = 1
    and date_diff('day', u.account_created_at, sub.backend_created_at) = 0
    and u.account_created_at between date '2026-01-01' and current_date - interval '7' day
    and s.account_source != 'Missing'
)
SELECT
    account_source,
    -- case when account_source = 'web' then partner else null end as partner,
    COUNT(analytics_id) AS subscriber_count,
    count(case when count_d7_tracking_points >= 5 AND count_d7_tracking_days >= 2 then analytics_id else null end) as activated_subscribers,
    cast(count(case when count_d7_tracking_points >= 5 AND count_d7_tracking_days >= 2 then analytics_id else null end) as double) / count(analytics_id) as activation_rate
FROM daily_converters
join user_metrics.new_user_activation_metrics using(analytics_id)
join (select analytics_id from der.sessions where session_start >= date '2026-01-01' group by 1) using(analytics_id)
GROUP BY 1
ORDER BY 1 DESC, 3 DESC;
