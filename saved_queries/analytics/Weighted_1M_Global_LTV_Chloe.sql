WITH weights AS (
    SELECT 
        last_country_name AS country, 
        platform,
        COUNT(DISTINCT master_id) AS weight,
        COUNT(1) AS weight_check
    FROM der.subscriptions_events
    LEFT JOIN der.sp_users
        USING(master_id)
    WHERE subscription_type = 'Subscription Purchased'
        AND backend_created_at > '2022-05-01'
    GROUP BY last_country_name, platform
)

SELECT
    created_execution_date,
    SUM(weight) AS total_weight,
    SUM(weight * ltv) / total_weight AS weighted_ltv
FROM der.ltv_with_promo_per_country
JOIN weights
    USING(country, platform)
WHERE --country IN ('United States') AND
    country in ('Austria', 'Belgium', 'Denmark', 'France',
          'Germany', 'Ireland', 'Luxembourg', 'Netherlands',
          'Norway', 'Sweden', 'Switzerland', 'United Kingdom', 'Italy', 'Spain',
          'Australia', 'Canada', 'Japan', 'New Zealand') AND
    platform = 'IOS' AND
    subscription_duration = 1
    AND created_execution_date >= '2021-07-01'
    AND retention_curve = 35
group by created_execution_date
order by created_execution_date

