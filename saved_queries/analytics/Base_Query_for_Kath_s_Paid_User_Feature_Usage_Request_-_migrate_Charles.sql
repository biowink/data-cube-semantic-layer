SELECT modes.mode AS feature,
        'mode' AS feature_type,
       COUNT(DISTINCT base.analytics_id) AS count_users,
       CAST(COUNT(DISTINCT base.analytics_id) AS DOUBLE) / 969340 AS pct_users
FROM der.clue_plus_user_lifetimes base
LEFT JOIN der.clue_plus_user_lifetimes modes ON base.analytics_id = modes.analytics_id
    AND modes.date BETWEEN DATE '{{ start_date }}' AND DATE '{{ end_date }}'
WHERE base.date = DATE '{{ end_date }}' AND base.is_paid_subscribed AND base.is_mau
GROUP BY 1, 2
UNION ALL
SELECT events.mobile_event_name AS feature,
        'analysis tab' AS feature_type,
       COUNT(DISTINCT base.analytics_id) AS count_users,
       CAST(COUNT(DISTINCT base.analytics_id) AS DOUBLE) / 969340 AS pct_users
FROM der.clue_plus_user_lifetimes base
INNER JOIN der.events ON base.analytics_id = events.analytics_id
    AND events.derived_tstamp BETWEEN DATE '{{ start_date }}' AND DATE '{{ end_date }}'
WHERE base.date = DATE '{{ end_date }}' AND base.is_paid_subscribed AND base.is_mau
  AND mobile_event_name IN (
                           'Show Cycle Length',
                           'Show Cycle Variation',
                           'Show Article',
                           'Show Period Cramps Charts',
                           'Show Feelings Analysis',
                           'Show BBT Charts',
                           'Show Sleep Charts',
                           'Open Clue Connect Share Sheet',
                           'Show Oura Temperature Charts'
                           )
GROUP BY 1, 2
ORDER BY 2 DESC, 1
;