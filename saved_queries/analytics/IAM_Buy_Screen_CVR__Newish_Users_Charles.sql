SELECT platform,
       DATE_TRUNC('week', derived_tstamp) AS week,
       COUNT(*) AS count,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Subscription Started' THEN session_id END) * 1.0/
        COUNT(DISTINCT CASE WHEN mobile_event_name = 'View Subscription Plans' THEN session_id END) AS iam_buy_screen_cvr
FROM der.events
INNER JOIN der.users USING (analytics_id)
WHERE platform IN ('ios', 'android')
    AND derived_tstamp >= DATE '2024-06-01'
    AND mobile_event_name IN ('View Subscription Plans', 'Subscription Started')
    AND navigation_context IN ('in-app-message', 'in app message', 'app open')
    AND DATE_DIFF('day', account_created_at, derived_tstamp) BETWEEN 0 AND 60
    GROUP BY 1, 2
    HAVING COUNT(*) > 100000
    ORDER BY 1, 2
    ;