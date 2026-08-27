WITH wellhub_cohorts AS (
    SELECT
        analytics_id,
        DATE_TRUNC('month', gympass_user_created_at) AS cohort_month,
        calendar.date,
        DATE_DIFF('month', DATE_TRUNC('month', gympass_user_created_at), calendar.date) AS months_into_lifecycle,
        SUM(CASE WHEN calendar."date" = DATE_TRUNC('month', backend_created_at) THEN revenue_eur ELSE 0 END) AS monthly_revenue
    FROM
        der.gympass_analytics
    CROSS JOIN static.calendar
    WHERE
        calendar."date" >= DATE_TRUNC('month', gympass_user_created_at)
        AND calendar."date" < DATE_TRUNC('month', CURRENT_DATE)
        AND day_is_first_of_month
        AND gympass_user_created_at >= DATE('2023-11-01')
    GROUP BY
        1,
        2,
        3,
        4
),
        monthly_values AS (
    SELECT
        cohort_month,
        months_into_lifecycle,
        AVG (monthly_revenue * 1.0) AS avg_monthly_revenue
    FROM
        wellhub_cohorts
    WHERE analytics_id IN (SELECT analytics_id FROM der.gympass_analytics WHERE revenue > 0)
    GROUP BY
        1, 2
    )
SELECT cohort_month,
       months_into_lifecycle,
       SUM(avg_monthly_revenue) OVER (PARTITION BY cohort_month ORDER BY months_into_lifecycle ASC) AS empirical_ltv
FROM monthly_values
ORDER BY 1, 2
;