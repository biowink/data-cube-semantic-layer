WITH payback_periods AS (
    SELECT period_days
    FROM UNNEST(sequence(10, 730, 10)) AS t(period_days)
),

spend AS (
    SELECT
        DATE_TRUNC('month', date) AS spend_month,
        SUM(cost) AS spend
    FROM der.adjust_campaign_performance
    GROUP BY 1
),

sales_events AS (
    SELECT
        u.analytics_id,
        date_trunc('month', u.account_created_at) AS cohort_month,
        date_diff(
            'day',
            u.account_created_at,
            s.backend_created_at
        ) AS days_since_account_creation,
        CASE
            WHEN subscription_type IN (
              'Subscription Purchased',
              'Subscription Renewed',
              'Subscription Payable Action'
              )
                THEN gross_sales_euro
              WHEN subscription_type = 'Subscription Refunded'
                THEN -gross_sales_euro
              ELSE 0
        END AS gross_sales
    FROM der.all_subscriptions_events s
    JOIN der.users u
        ON s.analytics_id = u.analytics_id
    WHERE s.backend_created_at >= u.account_created_at
    AND u.account_created_at >= date '2022-01-01'
),

revenue_by_payback AS (
    SELECT
        s.cohort_month,
        p.period_days,
        SUM(
            CASE
                WHEN s.days_since_account_creation <= p.period_days
                THEN s.gross_sales
                ELSE 0
            END
        ) AS cumulative_gross_sales
    FROM (
        SELECT DISTINCT cohort_month
        FROM sales_events
    ) cohorts
    CROSS JOIN payback_periods p
    LEFT JOIN sales_events s
        ON s.cohort_month = cohorts.cohort_month
    GROUP BY 1, 2
)

SELECT
    r.cohort_month,
    r.period_days,
    s.spend,
    r.cumulative_gross_sales,
    CASE
        WHEN s.spend = 0 THEN NULL
        ELSE r.cumulative_gross_sales / s.spend
    END AS roas
FROM revenue_by_payback r
JOIN spend s
    ON r.cohort_month = s.spend_month
WHERE DATE_ADD('day', r.period_days, DATE_ADD('month', 1, r.cohort_month)) < DATE_TRUNC('day', current_timestamp)
ORDER BY 1, 2;


