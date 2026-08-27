DROP TABLE test.predicted_segmented_renewal_rates;

CREATE TABLE test.predicted_segmented_renewal_rates AS (
WITH avg_renewal_rates AS (
    SELECT
        initial_subscription_duration,
        months_into_lifecycle,
        market,
        first_platform as platform,
        AVG(CASE WHEN is_subscribed THEN 1::FLOAT ELSE 0 END) AS average_market_renewal_rate
    FROM der.subscriber_monthly_retention
    JOIN der.sp_users USING(user_id)
    JOIN intermediate.market_mapping ON (sp_users.first_country_name = market_mapping.country)
    WHERE user_conversion_cohort != '2019-11-01'
    GROUP BY initial_subscription_duration, months_into_lifecycle, market, platform
),

avg_renewal_rate_derivative AS (
    SELECT
        initial_subscription_duration,
        months_into_lifecycle,
        market,
        platform,
        average_market_renewal_rate,
        average_market_renewal_rate::FLOAT / FIRST_VALUE(average_market_renewal_rate) OVER (PARTITION BY initial_subscription_duration, market, platform 
                                                                                            ORDER BY months_into_lifecycle
                                                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS avg_market_percent_dropoff_from_first_renewal   
    FROM avg_renewal_rates
    WHERE CASE WHEN initial_subscription_duration = 12 THEN months_into_lifecycle IN (12, 24)
               WHEN initial_subscription_duration = 1 THEN months_into_lifecycle BETWEEN 1 AND 35
               WHEN initial_subscription_duration = 6 THEN months_into_lifecycle IN (6,12,18,24)
               ELSE FALSE END
    ORDER BY initial_subscription_duration, months_into_lifecycle, market, platform
),

most_recent_cohort_by_subscription_type AS (
    SELECT
        initial_subscription_duration,
        months_into_lifecycle,
        MAX(user_conversion_cohort) AS most_recent_user_conversion_cohort
    FROM der.subscriber_monthly_retention
    GROUP BY initial_subscription_duration, months_into_lifecycle
),

recent_first_renewal_rate_by_country AS (
    SELECT
        initial_subscription_duration,
        first_country_name as country,
        first_platform as platform,
        AVG(CASE WHEN is_subscribed then 1::FLOAT ELSE 0 END) AS recent_first_renewal_rate,
        CASE WHEN COUNT(user_id) > 30 THEN TRUE ELSE FALSE END AS sufficient_sample_size
    FROM der.subscriber_monthly_retention
    JOIN der.sp_users USING(user_id)
    JOIN most_recent_cohort_by_subscription_type USING(initial_subscription_duration, months_into_lifecycle)
    
    WHERE user_conversion_cohort between most_recent_user_conversion_cohort - '90 days'::interval and most_recent_user_conversion_cohort
      AND CASE WHEN initial_subscription_duration = 12 THEN months_into_lifecycle = 12
               WHEN initial_subscription_duration = 1 THEN months_into_lifecycle = 1 
               WHEN initial_subscription_duration = 6 THEN months_into_lifecycle = 6 
               ELSE NULL END
    GROUP BY initial_subscription_duration, country, platform
),

recent_first_renewal_rate_by_market AS (
    SELECT
        initial_subscription_duration,
        market,
        first_platform as platform,
        AVG(CASE WHEN is_subscribed then 1::FLOAT ELSE 0 END) AS recent_first_renewal_rate
    FROM der.subscriber_monthly_retention
    JOIN der.sp_users USING(user_id)
    JOIN intermediate.market_mapping ON (sp_users.first_country_name = market_mapping.country)
    JOIN most_recent_cohort_by_subscription_type USING(initial_subscription_duration, months_into_lifecycle)
    WHERE user_conversion_cohort between most_recent_user_conversion_cohort - '90 days'::interval and most_recent_user_conversion_cohort
      AND CASE WHEN initial_subscription_duration = 12 THEN months_into_lifecycle = 12
               WHEN initial_subscription_duration = 1 THEN months_into_lifecycle = 1 
               WHEN initial_subscription_duration = 6 THEN months_into_lifecycle = 6 
               ELSE NULL END
    GROUP BY initial_subscription_duration, market, platform
),

distinct_country_list AS (
    SELECT first_country_name as country
    FROM der.sp_users
    WHERE first_country_name IS NOT NULL
    GROUP BY first_country_name
)

SELECT
    initial_subscription_duration, 
    months_into_lifecycle,
    distinct_country_list.country,
    platform,
    sufficient_sample_size,
    average_market_renewal_rate,
    avg_market_percent_dropoff_from_first_renewal,
    recent_first_renewal_rate_by_country.recent_first_renewal_rate as recent_first_renewal_rate_country,
    recent_first_renewal_rate_by_market.recent_first_renewal_rate as recent_first_renewal_rate_market,
    percent_dropoff_from_first_renewal 
        * CASE WHEN sufficient_sample_size THEN recent_first_renewal_rate_by_country.recent_first_renewal_rate
               ELSE recent_first_renewal_rate_by_market.recent_first_renewal_rate END
        AS predicted_renewal_rate
FROM distinct_country_list
JOIN intermediate.market_mapping USING(country)
JOIN avg_renewal_rate_derivative USING(market)
LEFT JOIN recent_first_renewal_rate_by_country USING(initial_subscription_duration, country, platform)
LEFT JOIN recent_first_renewal_rate_by_market USING(initial_subscription_duration, market, platform)
ORDER BY initial_subscription_duration, months_into_lifecycle, country, platform
);