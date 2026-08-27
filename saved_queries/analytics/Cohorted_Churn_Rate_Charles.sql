WITH cohorts AS (
    SELECT
        account_created_month,
        month,
        DATEDIFF('month', account_created_month, month) AS month_into_lifecycle,
        SUM(net_mau) AS net_mau
    FROM rep.monthly_active_user_growth
    WHERE
        account_created_month BETWEEN '2021-01-01' AND '2023-08-01'
        AND month >= monthly_active_user_growth.account_created_month
    GROUP BY 1, 2, 3
    ORDER BY 1, 2
),
    cohort_churn AS (
        SELECT
            month_into_lifecycle,
            net_mau,
            -1 * (net_mau - LAG(net_mau)
                            OVER (PARTITION BY account_created_month ORDER BY month_into_lifecycle ASC))::FLOAT /
            LAG(net_mau)
            OVER (PARTITION BY account_created_month ORDER BY month_into_lifecycle ASC) AS churn_rate
        FROM cohorts
    )
SELECT month_into_lifecycle,
       AVG(churn_rate::FLOAT) AS cohorted_churn_rate
FROM cohort_churn
WHERE month_into_lifecycle BETWEEN 1 AND 24
GROUP BY 1
ORDER BY 1
;