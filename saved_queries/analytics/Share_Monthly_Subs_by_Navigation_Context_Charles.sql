SELECT
    JSON_EXTRACT_PATH_TEXT(event_properties, 'Navigation Context') AS navigation_context,
    COUNT(*) AS count_subscriptions,
    AVG(CASE
            WHEN JSON_EXTRACT_PATH_TEXT(event_properties, 'Product Id') NOT LIKE '%12m%' THEN 1::FLOAT
            ELSE 0
        END) * 100 AS share_monthly_sub
FROM der.sorted_events
WHERE
    mobile_event_name = 'Subscription Started'
    AND derived_tstamp >= CURRENT_DATE - 90
GROUP BY 1
HAVING count_subscriptions > 100
ORDER BY 3 DESC
;