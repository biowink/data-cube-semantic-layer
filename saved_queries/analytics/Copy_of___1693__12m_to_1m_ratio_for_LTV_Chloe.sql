SELECT 
    DATE_TRUNC('month', backend_created_at) as month,
    COUNT(CASE WHEN subscription_duration = 12 then 1 else null end)::float / count(1) as share_of_12m_subscriptions
FROM der.subscriptions_events
WHERE subscription_type = 'Subscription Purchased'
    AND backend_created_at > '2021-07-01'
    AND platform = 'IOS'
    -- AND country = 'United States'
    AND country in ('Austria', 'Belgium', 'Denmark', 'France',
          'Germany', 'Ireland', 'Luxembourg', 'Netherlands',
          'Norway', 'Sweden', 'Switzerland', 'United Kingdom', 'Italy', 'Spain',
          'Australia', 'Canada', 'Japan', 'New Zealand')
GROUP BY month
ORDER BY month