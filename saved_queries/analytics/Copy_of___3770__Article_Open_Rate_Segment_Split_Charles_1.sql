SELECT
    events.platform || ', ' || CASE WHEN DATE_DIFF('day', account_Created_at, derived_tstamp) = 0 THEN 'new ' ELSE 'existing ' END AS segment,
    DATE_TRUNC('month', derived_tstamp) AS month,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Content Tab' THEN session_id END) AS opens,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Article' AND navigation_context = 'content' THEN session_id END) * 1.0/
        COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Content Tab' THEN session_id END) AS article_open_rate
FROM der.events
INNER JOIN der.users USING (analytics_id)
WHERE
    derived_tstamp >= DATE '2025-01-01'
    AND mobile_event_name IN ('Open Content Tab', 'Open Article')
GROUP BY 1, 2
ORDER BY 1, 2
;