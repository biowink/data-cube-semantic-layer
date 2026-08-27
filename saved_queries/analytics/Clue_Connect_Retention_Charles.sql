WITH partners AS (
    SELECT
        platform,
        analytics_id,
        MIN(derived_tstamp) AS first_connect_ts
    FROM
        der.events
    WHERE
        mobile_event_name = 'Open Partners Calendar'
        AND derived_tstamp >= DATE '2023-09-01'
        AND major_app_version > 100
    GROUP BY
        1,
        2
),
partners_cohorted AS (
SELECT partners.platform,
       DATE_TRUNC('month', first_connect_ts) AS cohort_month,
       calendar.date AS month,
       DATE_DIFF('month', DATE_TRUNC('month', first_connect_ts), calendar.date) AS months_into_lifecyle,
       COUNT(DISTINCT partners.analytics_id) AS cohort_size,
        COUNT(DISTINCT events.analytics_id) AS count_retained,
        COUNT(DISTINCT events.analytics_id) * 1.0 / COUNT(DISTINCT partners.analytics_id) AS retention_rate,
        COUNT(DISTINCT events.analytics_id || CAST(DATE(derived_tstamp) AS VARCHAR)) * 1.0 / (COUNT(DISTINCT events.analytics_id) * 30) AS dau_mau
FROM partners
CROSS JOIN static.calendar
LEFT JOIN der.events ON calendar.date = DATE_TRUNC('month', derived_tstamp)
                    AND derived_tstamp >= DATE '2023-09-01'
                     AND mobile_event_name = 'Open Partners Calendar'
                     AND events.analytics_id = partners.analytics_id
WHERE calendar.date < CURRENT_DATE AND day_is_first_of_month
    AND calendar.date >= DATE_TRUNC('month', first_connect_ts)
    -- AND partners.platform = 'ios'
GROUP BY 1, 2, 3, 4
),
sharers AS (
    SELECT
        platform,
        analytics_id,
        MIN(derived_tstamp) AS first_connect_ts
    FROM
        der.events
    WHERE
        mobile_event_name IN ('Did Share Clue Connect Code', 'Select Copy Clue Connect Invite Code')
        AND derived_tstamp >= DATE '2023-09-01'
        AND major_app_version > 100
    GROUP BY
        1,
        2
),
sharers_cohorted AS (
SELECT sharers.platform,
       DATE_TRUNC('month', first_connect_ts) AS cohort_month,
       calendar.date AS month,
       DATE_DIFF('month', DATE_TRUNC('month', first_connect_ts), calendar.date) AS months_into_lifecyle,
       COUNT(DISTINCT sharers.analytics_id) AS cohort_size,
        COUNT(DISTINCT events.analytics_id) AS count_retained,
        COUNT(DISTINCT events.analytics_id) * 1.0 / COUNT(DISTINCT sharers.analytics_id) AS retention_rate,
        COUNT(DISTINCT events.analytics_id || CAST(DATE(derived_tstamp) AS VARCHAR)) * 1.0 / (COUNT(DISTINCT events.analytics_id) * 30) AS dau_mau
FROM sharers
CROSS JOIN static.calendar
LEFT JOIN der.events ON calendar.date = DATE_TRUNC('month', derived_tstamp)
                    AND derived_tstamp >= DATE '2023-09-01'
                     AND mobile_event_name = 'Open Cycle View'
                     AND events.analytics_id = sharers.analytics_id
WHERE calendar.date < CURRENT_DATE AND day_is_first_of_month
    AND calendar.date >= DATE_TRUNC('month', first_connect_ts)
    -- AND sharers.platform = 'ios'
GROUP BY 1, 2, 3, 4
)
SELECT months_into_lifecyle, 'viewer' AS user_type, AVG(retention_rate) AS avg_retention_rate
FROM partners_cohorted
GROUP BY 1
HAVING COUNT(*) > 1
UNION ALL
SELECT months_into_lifecyle, 'sharer' AS user_type, AVG(retention_rate) AS avg_retention_rate
FROM sharers_cohorted
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY 1, 2