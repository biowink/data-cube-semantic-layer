WITH strategic_market AS (
        SELECT country
        FROM static.market_mapping
        WHERE market IN ('US', 'Strategic Europe', 'Strategic w/o US and Europe')
    ), 
target_month_range AS (
            SELECT date_add('year', -1, MIN(month))::DATE AS starting_month FROM static.company_targets
        ),
actual_1m_renewals AS (
    SELECT
        date_add('month', 1, subscriber_monthly_retention.user_conversion_cohort) AS month,
        AVG(CASE
                WHEN months_into_lifecycle = 1 AND is_subscribed THEN 1::FLOAT
                WHEN months_into_lifecycle = 1 AND NOT is_subscribed THEN 0
            END) AS strama_1m_renewal,
        COUNT(CASE
                WHEN months_into_lifecycle = 1 then 1 else null
            END) AS strama_1m_up_for_renewals
    FROM der.subscriber_monthly_retention
    JOIN der.sp_users USING (analytics_id)
    WHERE
            date_add('month', 1, subscriber_monthly_retention.user_conversion_cohort) >= (
            SELECT starting_month
            FROM target_month_range
        )
        AND last_country_name IN (SELECT country
                             FROM strategic_market)
        AND initial_subscription_duration = 1
        --AND month = '2023-05-01'
    GROUP BY 1
),
actual_12m_renewals AS (
    SELECT
        date_add('year', 1, subscriber_monthly_retention.user_conversion_cohort) AS month,
        AVG(CASE
                WHEN months_into_lifecycle = 12 AND is_subscribed THEN 1::FLOAT
                WHEN months_into_lifecycle = 12 AND NOT is_subscribed THEN 0
            END) AS strama_12m_renewal,
        COUNT(CASE
                WHEN months_into_lifecycle = 12 then 1 else null
            END) AS strama_12m_up_for_renewals
    FROM der.subscriber_monthly_retention
    JOIN der.sp_users USING (analytics_id)
    WHERE
            date_add('year', 1, subscriber_monthly_retention.user_conversion_cohort) >= (
            SELECT starting_month
            FROM target_month_range
        )
        AND last_country_name IN (SELECT country
                             FROM strategic_market)
        AND initial_subscription_duration = 12
        --AND month = '2023-05-01'
    GROUP BY 1
)

select
    month,
    strama_12m_renewal,
    strama_12m_up_for_renewals,
    strama_1m_renewal,
    strama_1m_up_for_renewals
from actual_1m_renewals
left join actual_12m_renewals using(month)
where month = '2023-05-01'