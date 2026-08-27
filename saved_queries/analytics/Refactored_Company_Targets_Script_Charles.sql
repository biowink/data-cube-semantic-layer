WITH strategic_market AS (
    SELECT country FROM static.market_mapping WHERE market IN ('US', 'Strategic Europe', 'Strategic w/o US and Europe')
),
    target_month_range AS (
        SELECT date_add('year', -1, MIN(month))::DATE AS starting_month FROM static.company_targets
    ),
    actual_sales AS (
        SELECT
            DATE_TRUNC('month', backend_created_at) AS month,
            SUM(CASE
                    WHEN subscription_type IN ('Subscription Purchased', 'Subscription Renewed') THEN gross_sales_euro
                    WHEN subscription_type IN ('Subscription Refunded') THEN -1 * gross_sales_euro
                END) AS global_gross_sales,
            SUM(CASE
                    WHEN subscription_type IN ('Subscription Purchased') THEN gross_sales_euro
                    WHEN subscription_type IN ('Subscription Refunded') THEN -1 * gross_sales_euro
                END) AS global_gross_sales_purchases,
            SUM(CASE
                    WHEN subscription_type IN ('Subscription Renewed') THEN gross_sales_euro
                END) AS global_gross_sales_renewals,
            SUM(CASE
                    WHEN subscription_type = 'Subscription Purchased' OR reactivation THEN 1
                    WHEN subscription_type = 'Subscription Refunded' THEN -1
                END) AS global_new_subscriptions,
            SUM(CASE
                    WHEN subscription_type IN ('Subscription Purchased', 'Subscription Renewed') AND country IN (
                        SELECT country
                        FROM strategic_market
                    ) THEN gross_sales_euro
                    WHEN subscription_type IN ('Subscription Refunded') AND country IN (
                        SELECT country
                        FROM strategic_market
                    ) THEN -1 * gross_sales_euro
                END) AS strategic_markets_gross_sales,
            SUM(CASE
                    WHEN subscription_type IN ('Subscription Purchased') AND country IN (
                        SELECT country
                        FROM strategic_market
                    ) THEN gross_sales_euro
                    WHEN subscription_type IN ('Subscription Refunded') AND country IN (
                        SELECT country
                        FROM strategic_market
                    ) THEN -1 * gross_sales_euro
                END) AS strategic_markets_gross_sales_purchases,
            SUM(CASE
                    WHEN subscription_type IN ('Subscription Renewed') AND country IN (
                        SELECT country
                        FROM strategic_market
                    ) THEN gross_sales_euro
                END) AS strategic_markets_gross_sales_renewals,
            SUM(CASE
                    WHEN (subscription_type = 'Subscription Purchased' OR reactivation) AND country IN (
                        SELECT country
                        FROM strategic_market
                    ) THEN 1
                    WHEN subscription_type = 'Subscription Refunded' AND country IN (
                        SELECT country
                        FROM strategic_market
                    ) THEN -1
                END) AS strategic_markets_new_subscriptions
        FROM der.subscriptions_events
        WHERE
                DATE_TRUNC('month', backend_created_at) >= (
                SELECT starting_month
                FROM target_month_range
            )
        GROUP BY 1
    ),
    actual_new_users AS (
        SELECT
            DATE_TRUNC('month', first_seen) AS month,
            COUNT(DISTINCT master_id) AS global_new_users,
            COUNT(DISTINCT CASE
                               WHEN first_country_name IN (
                                   SELECT country
                                   FROM strategic_market
                               ) THEN master_id
                           END) AS strategic_markets_new_users
        FROM der.sp_users
        WHERE
                DATE_TRUNC('month', first_seen) >= (
                SELECT starting_month
                FROM target_month_range
            )
        GROUP BY 1
    ),
    actual_flows AS (
        SELECT
            month,
            SUM(CASE
                    WHEN NOT is_subscribed AND is_converter THEN 0
                    WHEN is_converter OR is_reactivation THEN 1
                    WHEN is_churner THEN -1
                END) AS global_net_subscriber_flow,
                SUM(CASE WHEN is_churner AND months_into_lifecycle > 0 THEN 1 END)::FLOAT /
                SUM(CASE WHEN lagged_is_subscribed THEN 1 END) AS global_churn_rate
        FROM der.subscriber_monthly_retention
        WHERE
                month >= (
                SELECT starting_month
                FROM target_month_range
            )
        GROUP BY 1
    ),
    actual_1m_renewals AS (
        SELECT
            date_add('month', 1, subscriber_monthly_retention.user_conversion_cohort) AS month,
            AVG(CASE
                    WHEN months_into_lifecycle = 1 AND is_subscribed THEN 1::FLOAT
                    WHEN months_into_lifecycle = 1 AND NOT is_subscribed THEN 0
                END) AS global_1m_renewal
        FROM der.subscriber_monthly_retention
        WHERE
                date_add('month', 1, subscriber_monthly_retention.user_conversion_cohort) >= (
                SELECT starting_month
                FROM target_month_range
            )
            AND initial_subscription_duration = 1
        GROUP BY 1
    ),
    actual_12m_renewals AS (
        SELECT
            date_add('year', 1, subscriber_monthly_retention.user_conversion_cohort) AS month,
            AVG(CASE
                    WHEN months_into_lifecycle = 12 AND is_subscribed THEN 1::FLOAT
                    WHEN months_into_lifecycle = 12 AND NOT is_subscribed THEN 0
                END) AS global_12m_renewal
        FROM der.subscriber_monthly_retention
        WHERE
                date_add('year', 1, subscriber_monthly_retention.user_conversion_cohort) >= (
                SELECT starting_month
                FROM target_month_range
            )
            AND initial_subscription_duration = 12
        GROUP BY 1
    ),
    actual_subscribers AS (
        SELECT
            DATE_TRUNC('month', date) AS month,
            COUNT(CASE WHEN subscription_status = 'subscribed_paid' THEN master_id END) AS global_paying_subscribers,
            COUNT(CASE
                      WHEN subscription_status = 'subscribed_paid' AND country_name IN (
                          SELECT country
                          FROM strategic_market
                      ) THEN master_id
                  END) AS strategic_markets_paying_subscribers
        FROM der.clue_plus_user_lifetimes
        WHERE
                DATE_TRUNC('month', date) >= (
                SELECT starting_month
                FROM target_month_range
            )
            AND EXTRACT('day' FROM date_add('day', 1, date)) = 1
        GROUP BY 1
    ),
    actual_existing_conversions AS (
        SELECT
            DATE_TRUNC('month', backend_created_at) AS month,
            SUM(CASE
                    WHEN subscription_type IN ('Subscription Purchased') THEN 1
                    WHEN subscription_type IN ('Subscription Refunded') THEN -1
                END) AS conversions_from_existing_users
        FROM der.subscriptions_events
        INNER JOIN der.sp_users
                USING (master_id)
        WHERE
                DATE_TRUNC('month', backend_created_at) >= (
                SELECT starting_month
                FROM target_month_range
            )
            AND backend_created_at::DATE - first_seen::DATE > 30
            AND country IN (
            SELECT country
            FROM strategic_market
        )
        GROUP BY 1
    ),
    actual_existing_users AS (
        SELECT
            DATE_TRUNC('month', start) AS month,
            COUNT(DISTINCT master_id) AS strategic_markets_existing_users
        FROM der.sp_sessions
        WHERE
                DATE_TRUNC('month', start) >= (
                SELECT starting_month
                FROM target_month_range
            )
            AND start::DATE - user_first_seen::DATE > 30
            AND country_name IN (
            SELECT country
            FROM strategic_market
        )
        GROUP BY 1
    ),
    actual_adjust_metrics AS (
        SELECT
            DATE_TRUNC('month', date) AS month,
            SUM(cost) AS strategic_markets_ua_budget,
                SUM(CASE WHEN NOT self_attributing_network THEN cost END)::FLOAT / SUM(CASE
                                                                                           WHEN NOT self_attributing_network
                                                                                               THEN d30_12m_subscription_conversions + d30_1m_subscription_conversions
                                                                                       END) AS strategic_markets_blended_d30_cac,
                SUM(CASE WHEN NOT self_attributing_network THEN cost END)::FLOAT /
                SUM(CASE WHEN NOT self_attributing_network THEN predicted_d360_conversions END) AS strategic_markets_blended_d360_cac,
                SUM(CASE WHEN NOT self_attributing_network AND network != 'Organic' THEN cost END)::FLOAT / SUM(CASE
                                                                                                                    WHEN NOT self_attributing_network AND network != 'Organic'
                                                                                                                        THEN d30_12m_subscription_conversions + d30_1m_subscription_conversions
                                                                                                                END) AS strategic_markets_paid_d30_cac,
                SUM(CASE WHEN NOT self_attributing_network AND network != 'Organic' THEN cost END)::FLOAT / SUM(CASE
                                                                                                                    WHEN NOT self_attributing_network AND network != 'Organic'
                                                                                                                        THEN predicted_d360_conversions
                                                                                                                END) AS strategic_markets_paid_d360_cac,
            SUM(CASE
                    WHEN NOT self_attributing_network AND network != 'Organic'
                        THEN d30_12m_subscription_conversions + d30_1m_subscription_conversions
                END) AS strategic_markets_paid_d30_conversions,
            SUM(CASE
                    WHEN NOT self_attributing_network AND network != 'Organic' THEN installs
                END) AS strategic_markets_paid_new_users,
                strategic_markets_paid_d30_conversions::FLOAT /
                strategic_markets_paid_new_users AS strategic_markets_paid_d30_cvr
        FROM der.adjust_campaign_performance
        WHERE
                DATE_TRUNC('month', date) >= (
                SELECT starting_month
                FROM target_month_range
            )
            AND country IN (
            SELECT country
            FROM strategic_market
        )
        GROUP BY 1
    ),
    actual_merged AS (
        SELECT
            month,
            'Global' AS segment,
            'Gross Sales' AS metric,
            global_gross_sales AS actual
        FROM actual_sales
        UNION ALL
        SELECT
            month,
            'Global' AS segment,
            'Gross Sales Purchases' AS metric,
            global_gross_sales_purchases AS actual
        FROM actual_sales
        UNION ALL
        SELECT
            month,
            'Global' AS segment,
            'Gross Sales Renewals' AS metric,
            global_gross_sales_renewals AS actual
        FROM actual_sales
        UNION ALL
        SELECT
            month,
            'Global' AS segment,
            'New Subscriptions' AS metric,
            global_new_subscriptions AS actual
        FROM actual_sales
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Gross Sales' AS metric,
            strategic_markets_gross_sales AS actual
        FROM actual_sales
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Gross Sales Purchases' AS metric,
            strategic_markets_gross_sales_purchases AS actual
        FROM actual_sales
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Gross Sales Renewals' AS metric,
            strategic_markets_gross_sales_renewals AS actual
        FROM actual_sales
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'New Subscriptions' AS metric,
            strategic_markets_new_subscriptions AS actual
        FROM actual_sales
        UNION ALL
        SELECT
            month,
            'Global' AS segment,
            'New Users' AS metric,
            global_new_users AS actual
        FROM actual_new_users
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'New Users' AS metric,
            strategic_markets_new_users AS actual
        FROM actual_new_users
        UNION ALL
        SELECT
            month,
            'Global' AS segment,
            'Net Subscriber Flow' AS metric,
            global_net_subscriber_flow AS actual
        FROM actual_flows
        UNION ALL
        SELECT
            month,
            'Global' AS segment,
            'Subscriber Churn Rate' AS metric,
            global_churn_rate AS actual
        FROM actual_flows
        UNION ALL
        SELECT
            month,
            'Global' AS segment,
            '1M Renewal Rate' AS metric,
            global_1m_renewal AS actual
        FROM actual_1m_renewals
        UNION ALL
        SELECT
            month,
            'Global' AS segment,
            '12M Renewal Rate' AS metric,
            global_12m_renewal AS actual
        FROM actual_12m_renewals
        UNION ALL
        SELECT
            month,
            'Global' AS segment,
            'Paying Subscribers' AS metric,
            global_paying_subscribers AS actual
        FROM actual_subscribers
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Paying Subscribers' AS metric,
            strategic_markets_paying_subscribers AS actual
        FROM actual_subscribers
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Conversions from Existing Users (D31+)' AS metric,
            conversions_from_existing_users AS actual
        FROM actual_existing_conversions
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Existing Users' AS metric,
            strategic_markets_existing_users AS actual
        FROM actual_existing_users
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'UA Budget' AS metric,
            strategic_markets_ua_budget AS actual
        FROM actual_adjust_metrics
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Blended D30 CAC' AS metric,
            strategic_markets_blended_d30_cac AS actual
        FROM actual_adjust_metrics
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Blended D360 CAC' AS metric,
            strategic_markets_blended_d360_cac AS actual
        FROM actual_adjust_metrics
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Paid D30 CAC' AS metric,
            strategic_markets_paid_d30_cac AS actual
        FROM actual_adjust_metrics
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Paid D360 CAC' AS metric,
            strategic_markets_paid_d360_cac AS actual
        FROM actual_adjust_metrics
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Paid D30 Conversions' AS metric,
            strategic_markets_paid_d30_conversions AS actual
        FROM actual_adjust_metrics
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Paid New Users' AS metric,
            strategic_markets_paid_new_users AS actual
        FROM actual_adjust_metrics
        UNION ALL
        SELECT
            month,
            'Strategic Markets' AS segment,
            'Paid D30 CVR' AS metric,
            strategic_markets_paid_d30_cvr AS actual
        FROM actual_adjust_metrics
    ),
    actual_calculations_derived AS (
        SELECT
            month,
            segment,
            'Existing MoM CVR' AS metric,
                SUM(CASE WHEN metric = 'Conversions from Existing Users (D31+)' THEN actual END)::FLOAT /
                SUM(CASE WHEN metric = 'Existing Users' THEN actual END) AS actual
        FROM actual_merged
        WHERE
            segment = 'Strategic Markets'
        GROUP BY 1, 2, 3
        UNION ALL
        SELECT
            month,
            segment,
            'Organic D30 CVR' AS metric,
                (SUM(CASE WHEN metric = 'New Subscriptions' THEN actual END) -
                 SUM(CASE WHEN metric = 'Paid D30 Conversions' THEN actual END) -
                 SUM(CASE WHEN metric = 'Conversions from Existing Users (D31+)' THEN actual END))::FLOAT /
                (SUM(CASE WHEN metric = 'New Users' THEN actual END) -
                 SUM(CASE WHEN metric = 'Paid New Users' THEN actual END)) AS actual
        FROM actual_merged
        WHERE
            segment = 'Strategic Markets'
        GROUP BY 1, 2, 3
        UNION ALL
        SELECT
            month,
            segment,
            'Organic D30 Conversions' AS metric,
                SUM(CASE WHEN metric = 'New Subscriptions' THEN actual END) -
                SUM(CASE WHEN metric = 'Paid D30 Conversions' THEN actual END) -
                SUM(CASE WHEN metric = 'Conversions from Existing Users (D31+)' THEN actual END) AS actual
        FROM actual_merged
        WHERE
            segment = 'Strategic Markets'
        GROUP BY 1, 2, 3
        UNION ALL
        SELECT
            month,
            segment,
            'Organic New Users' AS metric,
                SUM(CASE WHEN metric = 'New Users' THEN actual END) -
                SUM(CASE WHEN metric = 'Paid New Users' THEN actual END) AS actual
        FROM actual_merged
        WHERE
            segment = 'Strategic Markets'
        GROUP BY 1, 2, 3
    ),
    actual_calculations_unioned AS (
        SELECT * FROM actual_merged UNION ALL SELECT * FROM actual_calculations_derived
    ),
    targets_and_actuals_joined AS (
        SELECT
            month,
            segment,
            metric,
            planning_month,
            stakeholder,
            value,
            value_format,
            actual,
            LAG(value, 1) OVER (PARTITION BY segment, metric ORDER BY month) AS previous_month_value,
            LAG(actual, 1) OVER (PARTITION BY segment, metric ORDER BY month) AS previous_month_actual,
--          LAG(value, 12) OVER (PARTITION BY segment, metric ORDER BY month) AS previous_year_value,
            LAG(actual, 12) OVER (PARTITION BY segment, metric ORDER BY month) AS previous_year_actual
        FROM static.company_targets
        FULL OUTER JOIN actual_calculations_unioned
                USING (month, segment, metric)
    )
SELECT *
FROM targets_and_actuals_joined
WHERE
    month >= '2022-01-01'
ORDER BY month
;