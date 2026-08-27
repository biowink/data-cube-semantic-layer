WITH avg_renewal_rates AS (
    SELECT
        initial_subscription_duration,
        months_into_lifecycle,
        AVG(CASE WHEN is_subscribed THEN 1::FLOAT ELSE 0 END) AS renewal_rate
    FROM der.subscriber_monthly_retention
    WHERE user_conversion_cohort != '2019-11-01'
    GROUP BY initial_subscription_duration, months_into_lifecycle
),

avg_renewal_rate_derivative AS (
    SELECT
        initial_subscription_duration,
        months_into_lifecycle,
        renewal_rate::FLOAT / FIRST_VALUE(renewal_rate) OVER (PARTITION BY initial_subscription_duration ORDER BY months_into_lifecycle
                                                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS percent_dropoff_from_first_renewal    
    FROM avg_renewal_rates
    WHERE CASE WHEN initial_subscription_duration = 12 THEN months_into_lifecycle IN (12, 24)
               WHEN initial_subscription_duration = 1 THEN months_into_lifecycle BETWEEN 1 AND 35
               WHEN initial_subscription_duration = 6 THEN months_into_lifecycle IN (6,12,18,24)
               ELSE FALSE END
    ORDER BY initial_subscription_duration, months_into_lifecycle
),

most_recent_cohort_by_subscription_type AS (
    SELECT
        initial_subscription_duration,
        months_into_lifecycle,
        MAX(user_conversion_cohort) AS most_recent_user_conversion_cohort
    FROM der.subscriber_monthly_retention
    GROUP BY initial_subscription_duration, months_into_lifecycle
),

recent_first_renewal_rates AS (
    SELECT
        initial_subscription_duration,
        AVG(CASE WHEN is_subscribed then 1::FLOAT ELSE 0 END) AS recent_first_renewal_rate,
        COUNT(user_id) AS user_count_recent_period
    FROM der.subscriber_monthly_retention
    JOIN most_recent_cohort_by_subscription_type USING(initial_subscription_duration, months_into_lifecycle)
    WHERE user_conversion_cohort between most_recent_user_conversion_cohort - '90 days'::interval and most_recent_user_conversion_cohort
      AND CASE WHEN initial_subscription_duration = 12 THEN months_into_lifecycle = 12
               WHEN initial_subscription_duration = 1 THEN months_into_lifecycle = 1 
               WHEN initial_subscription_duration = 6 THEN months_into_lifecycle = 6 
               ELSE NULL END
    GROUP BY initial_subscription_duration
)

SELECT
    initial_subscription_duration, 
    months_into_lifecycle,
    percent_dropoff_from_first_renewal * recent_first_renewal_rate AS predicted_renewal_rate
FROM avg_renewal_rate_derivative
LEFT JOIN recent_first_renewal_rates USING(initial_subscription_duration)
ORDER BY initial_subscription_duration, months_into_lifecycle;
