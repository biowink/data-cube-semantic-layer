WITH revenue AS (
SELECT
    events.platform,
    DATE_TRUNC('week', clue_users.backend_created_at) AS week,
    COUNT(DISTINCT analytics_id) AS count_subscriptions,
    SUM(first_gross_sales_euro) AS purchase_sales
FROM core.clue_users
INNER JOIN der.events USING (analytics_id)
INNER JOIN der.subscription_history USING (analytics_id)
WHERE mobile_event_name = 'Subscription Started'
    AND derived_tstamp >= DATE '2026-01-01'
    AND DATE_DIFF('hour', backend_created_at, derived_tstamp) BETWEEN 0 AND 24
    AND navigation_context != 'onboarding'
    AND user_converted_with_this_subscription
    AND clue_users.backend_created_at BETWEEN DATE '2026-01-01' AND CURRENT_DATE - INTERVAL '8' DAY
GROUP BY 1, 2
),
    user_cohorts AS (
SELECT
    platform,
    DATE_TRUNC('week', clue_users.backend_created_at) AS week,
    COUNT(*) AS count_users
FROM core.clue_users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
WHERE
    platform IS NOT NULL
    AND clue_users.backend_created_at BETWEEN DATE '2026-01-01' AND CURRENT_DATE - INTERVAL '8' DAY
GROUP BY 1, 2
)
SELECT
    platform,
    week,
    count_users,
    count_subscriptions,
    purchase_sales,
    purchase_sales * 1.0/count_users AS arppu,
    count_subscriptions * 1.0/count_users AS cvr
FROM user_cohorts
INNER JOIN revenue USING (platform, week)
ORDER BY 1, 2
;