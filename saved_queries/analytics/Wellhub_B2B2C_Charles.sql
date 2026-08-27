WITH user_cohorts AS (
    SELECT
        analytics_id,
        MIN(DATE_TRUNC('month', backend_created_at)) AS cohort_month
    FROM
        der.all_subscriptions_events
    WHERE
        partner = 'gympass'
        AND subscription_type = 'Subscription Payable Action'
        AND backend_created_at < DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY
        1
),
    cohort_cross_join AS (
        SELECT
            cohort_month,
            month_index,
            COUNT(DISTINCT user_cohorts.analytics_id) AS cohort_size,
            SUM(gross_sales_euro) / COUNT(DISTINCT user_cohorts.analytics_id) AS avg_monthly_revenue
        FROM
            user_cohorts
            CROSS JOIN (
                SELECT
                    ROW_NUMBER() OVER (ORDER BY DATE) AS month_index
                FROM
                    static.calendar LIMIT 36
            ) AS indices
            LEFT JOIN der.all_subscriptions_events
                ON user_cohorts.analytics_id = all_subscriptions_events.analytics_id AND partner = 'gympass' AND
                   subscription_type = 'Subscription Payable Action' AND
                   DATE_TRUNC('month', backend_created_at) = DATE_ADD('month', month_index, cohort_month) AND
                   DATE_TRUNC('month', backend_created_at) >= cohort_month
        WHERE
            DATE_ADD('month', month_index, cohort_month) < DATE_TRUNC('month', CURRENT_DATE)
        GROUP BY
            1,
            2
    )
SELECT
    cohort_month,
    month_index,
    cohort_size,
    avg_monthly_revenue,
    SUM(avg_monthly_revenue) OVER (PARTITION BY cohort_month ORDER BY month_index ASC) AS empirical_ltv
FROM cohort_cross_join
ORDER BY 1, 2
;