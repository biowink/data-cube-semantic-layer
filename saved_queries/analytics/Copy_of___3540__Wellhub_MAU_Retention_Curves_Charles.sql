WITH cohorts AS (
    SELECT
        analytics_id,
        MIN(DATE_TRUNC('month', all_subscriptions_events.backend_created_at)) AS cohort_month
    FROM
        der.all_subscriptions_events
    INNER JOIN der.backend_gympass_users USING (analytics_id)
    WHERE
        subscription_type = 'Subscription Payable Action'
        AND partner = 'gympass'
        AND backend_created_at < DATE_TRUNC('month', CURRENT_DATE)
        AND plan_id = '1'
    GROUP BY
        1
),
    indices AS (
        SELECT ROW_NUMBER() OVER (ORDER BY date) - 1 AS idx
        FROM static.calendar
        ORDER BY "date"
        LIMIT 36
    )
SELECT cohort_month,
       idx AS months_into_lifetime,
       COUNT(DISTINCT cohorts.analytics_id) AS cohort_size,
       COUNT(DISTINCT all_subscriptions_events.analytics_id) * 1.0/
            COUNT(DISTINCT cohorts.analytics_id) AS retention_rate,
        SUM(gross_sales_euro) * 1.0/COUNT(DISTINCT cohorts.analytics_id) AS dollar_retention
FROM cohorts
CROSS JOIN indices
LEFT JOIN der.all_subscriptions_events ON cohorts.analytics_id = all_subscriptions_events.analytics_id
    AND subscription_type = 'Subscription Payable Action'
    AND partner = 'gympass'
    AND DATE_DIFF('month', cohort_month, DATE_TRUNC('month', backend_created_at)) = idx
WHERE idx < DATE_DIFF('month', cohort_month, DATE_TRUNC('month', CURRENT_DATE))
GROUP BY 1, 2
ORDER BY 1, 2
;