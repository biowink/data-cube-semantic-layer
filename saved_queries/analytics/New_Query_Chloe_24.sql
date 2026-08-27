WITH user_level_aggregate AS (
SELECT
    backend_adjust_trackers.user_id,

    DATE_TRUNC('day', install_time) AS date,
    COALESCE(NULLIF(SPLIT_PART(tracker_name,'::',1),''),'unknown') AS network,
    COALESCE(NULLIF(SPLIT_PART(tracker_name,'::',2),''),'unknown') AS campaign,
    CASE WHEN REGEXP_LIKE(SPLIT_PART(SPLIT_PART(SPLIT_PART(tracker_name,'::',2), '(', 2), ')', 1), '^[0-9]+$')
         THEN NULLIF(SPLIT_PART(SPLIT_PART(SPLIT_PART(tracker_name,'::',2), '(', 2), ')', 1),'')
         ELSE NULL END
         AS campaign_id,
    COALESCE(NULLIF(SPLIT_PART(tracker_name,'::',3),''),'unknown') AS adgroup,
    CASE WHEN REGEXP_LIKE(SPLIT_PART(SPLIT_PART(SPLIT_PART(tracker_name,'::',3), '(', 2), ')', 1), '^[0-9]+$')
         THEN NULLIF(SPLIT_PART(SPLIT_PART(SPLIT_PART(tracker_name,'::',3), '(', 2), ')', 1),'')
         ELSE NULL END
         AS adgroup_id,
    UPPER(user_first_session_attributes.country_code) AS country_code,
    user_first_session_attributes.country_name AS country,
    COALESCE(NULLIF(SPLIT_PART(tracker_name,'::',4),''),'unknown') AS creative,
    CASE WHEN REGEXP_LIKE(SPLIT_PART(SPLIT_PART(SPLIT_PART(tracker_name,'::',4), '(', 2), ')', 1), '^[0-9]+$')
         THEN NULLIF(SPLIT_PART(SPLIT_PART(SPLIT_PART(tracker_name,'::',4), '(', 2), ')', 1),'')
         ELSE NULL END
         AS creative_id,
    user_first_session_attributes.platform,

    -- d0
    MAX(CASE WHEN CAST(users.backend_created_at AS DATE) = CAST(install_time AS DATE) THEN 1 ELSE 0 END)
        AS d0_created_account_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Free Trial'
              AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(install_time AS DATE)
              THEN 1 ELSE 0 END
        ) AS d0_free_trial_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(install_time AS DATE)
              THEN 1 ELSE 0 END
        ) AS d0_1m_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(install_time AS DATE)
              THEN gross_sales_euro ELSE 0 END
        ) AS d0_1m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(install_time AS DATE)
              THEN 1 ELSE 0 END
        ) AS d0_12m_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(install_time AS DATE)
              THEN gross_sales_euro ELSE 0 END
        ) AS d0_12m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Granted'
              AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(install_time AS DATE)
              THEN 1 ELSE 0 END
        ) AS d0_partner_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Payable Action'
              AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(install_time AS DATE)
              THEN gross_sales_euro ELSE 0 END
        ) AS d0_partner_subscription_revenue,

    -- d7
    MAX(CASE WHEN users.backend_created_at BETWEEN install_time AND install_time + INTERVAL '7' day
              THEN 1 ELSE 0 END
        ) AS d7_created_account_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Free Trial'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
              THEN 1 ELSE 0 END
        ) AS d7_free_trial_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
              THEN 1 ELSE 0 END
        ) AS d7_1m_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
              THEN gross_sales_euro ELSE 0 END
        ) AS d7_1m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
              THEN 1 ELSE 0 END
        ) AS d7_12m_subscription_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND all_subscriptions_events.is_in_intro_offer_period = TRUE
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
              THEN 1 ELSE 0 END
        ) AS d7_12m_promo_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
              THEN gross_sales_euro ELSE 0 END
        ) AS d7_12m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Granted'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
              THEN 1 ELSE 0 END
        ) AS d7_partner_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Payable Action'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
              THEN gross_sales_euro ELSE 0 END
        ) AS d7_partner_subscription_revenue,

    -- d30
    MAX(CASE WHEN users.backend_created_at BETWEEN install_time AND install_time + INTERVAL '30' day
              THEN 1 ELSE 0 END
        ) AS d30_created_account_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Free Trial'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 30
              THEN 1 ELSE 0 END
        ) AS d30_free_trial_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 30
              THEN 1 ELSE 0 END
        ) AS d30_1m_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 30
              THEN gross_sales_euro ELSE 0 END
        ) AS d30_1m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 30
              THEN 1 ELSE 0 END
        ) AS d30_12m_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 30
              THEN gross_sales_euro ELSE 0 END
        ) AS d30_12m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Granted'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 30
              THEN 1 ELSE 0 END
        ) AS d30_partner_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Payable Action'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 30
              THEN gross_sales_euro ELSE 0 END
        ) AS d30_partner_subscription_revenue,

    -- d120
    MAX(CASE WHEN users.backend_created_at BETWEEN install_time AND install_time + INTERVAL '120' day
              THEN 1 ELSE 0 END
        ) AS d120_created_account_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Free Trial'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 120
              THEN 1 ELSE 0 END
        ) AS d120_free_trial_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 120
              THEN 1 ELSE 0 END
        ) AS d120_1m_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 120
              THEN gross_sales_euro ELSE 0 END
        ) AS d120_1m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 120
              THEN 1 ELSE 0 END
        ) AS d120_12m_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 120
              THEN gross_sales_euro ELSE 0 END
        ) AS d120_12m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Granted'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 120
              THEN 1 ELSE 0 END
        ) AS d120_partner_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Payable Action'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 120
              THEN gross_sales_euro ELSE 0 END
        ) AS d120_partner_subscription_revenue,

    -- d360
    MAX(CASE WHEN users.backend_created_at BETWEEN install_time AND install_time + INTERVAL '360' day
              THEN 1 ELSE 0 END
        ) AS d360_created_account_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Free Trial'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 360
              THEN 1 ELSE 0 END
        ) AS d360_free_trial_conversion,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 360
              THEN 1 ELSE 0 END
        ) AS d360_1m_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 1
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 360
              THEN gross_sales_euro ELSE 0 END
        ) AS d360_1m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 360
              THEN 1 ELSE 0 END
        ) AS d360_12m_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
              AND all_subscriptions_events.subscription_duration = 12
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 360
              THEN gross_sales_euro ELSE 0 END
        ) AS d360_12m_subscription_revenue,
    MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Granted'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 360
              THEN 1 ELSE 0 END
        ) AS d360_partner_subscription_conversion,
    SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Payable Action'
              AND DATE_DIFF('day', CAST(users.backend_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 360
              THEN gross_sales_euro ELSE 0 END
        ) AS d360_partner_subscription_revenue

FROM der.backend_adjust_trackers
JOIN import.users
    ON (backend_adjust_trackers.user_id = users.user_id)
LEFT JOIN user_metrics.user_first_session_attributes
    ON (users.analytics_id = user_first_session_attributes.analytics_id)
LEFT JOIN der.all_subscriptions_events
    ON (users.analytics_id = all_subscriptions_events.analytics_id
        AND (all_subscriptions_events.subscription_type IN ('Subscription Free Trial', 'Subscription Purchased')
             OR all_subscriptions_events.subscription_type IN ('Subscription Granted', 'Subscription Payable Action') AND partner IS NOT NULL)
        AND all_subscriptions_events.backend_created_at BETWEEN backend_adjust_trackers.install_time AND backend_adjust_trackers.install_time + INTERVAL '120' day)
WHERE tracker_name != 'TikTok SAN'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
),

intermediate_backend_campaign_performance as (
    SELECT
        date,
        network,
        campaign,
        user_level_aggregate.campaign_id,
        adgroup,
        adgroup_id,
        country_code,
        country,
        creative,
        creative_id,
        platform,
    
        SUM(d0_created_account_conversion) AS d0_created_account_conversions,
        SUM(d0_free_trial_conversion) AS d0_free_trial_conversions,
        SUM(d0_1m_subscription_conversion) AS d0_1m_subscription_conversions,
        SUM(d0_1m_subscription_revenue) AS d0_1m_subscription_revenue,
        SUM(d0_12m_subscription_conversion) AS d0_12m_subscription_conversions,
        SUM(d0_12m_subscription_revenue) AS d0_12m_subscription_revenue,
        SUM(d0_partner_subscription_conversion) AS d0_partner_subscription_conversions,
        SUM(d0_partner_subscription_revenue) AS d0_partner_subscription_revenue,
    
        SUM(d7_created_account_conversion) AS d7_created_account_conversions,
        SUM(d7_free_trial_conversion) AS d7_free_trial_conversions,
        SUM(d7_1m_subscription_conversion) AS d7_1m_subscription_conversions,
        SUM(d7_1m_subscription_revenue) AS d7_1m_subscription_revenue,
        SUM(d7_12m_subscription_conversion) AS d7_12m_subscription_conversions,
        SUM(d7_12m_promo_subscription_conversion) as d7_12m_promo_subscription_conversions,
        SUM(d7_12m_subscription_revenue) AS d7_12m_subscription_revenue,
        SUM(d7_partner_subscription_conversion) AS d7_partner_subscription_conversions,
        SUM(d7_partner_subscription_revenue) AS d7_partner_subscription_revenue,
    
        SUM(d30_created_account_conversion) AS d30_created_account_conversions,
        SUM(d30_free_trial_conversion) AS d30_free_trial_conversions,
        SUM(d30_1m_subscription_conversion) AS d30_1m_subscription_conversions,
        SUM(d30_1m_subscription_revenue) AS d30_1m_subscription_revenue,
        SUM(d30_12m_subscription_conversion) AS d30_12m_subscription_conversions,
        SUM(d30_12m_subscription_revenue) AS d30_12m_subscription_revenue,
        SUM(d30_partner_subscription_conversion) AS d30_partner_subscription_conversions,
        SUM(d30_partner_subscription_revenue) AS d30_partner_subscription_revenue,
    
        SUM(d120_created_account_conversion) AS d120_created_account_conversions,
        SUM(d120_free_trial_conversion) AS d120_free_trial_conversions,
        SUM(d120_1m_subscription_conversion) AS d120_1m_subscription_conversions,
        SUM(d120_1m_subscription_revenue) AS d120_1m_subscription_revenue,
        SUM(d120_12m_subscription_conversion) AS d120_12m_subscription_conversions,
        SUM(d120_12m_subscription_revenue) AS d120_12m_subscription_revenue,
        SUM(d120_partner_subscription_conversion) AS d120_partner_subscription_conversions,
        SUM(d120_partner_subscription_revenue) AS d120_partner_subscription_revenue,
    
        SUM(d360_created_account_conversion) AS d360_created_account_conversions,
        SUM(d360_free_trial_conversion) AS d360_free_trial_conversions,
        SUM(d360_1m_subscription_conversion) AS d360_1m_subscription_conversions,
        SUM(d360_1m_subscription_revenue) AS d360_1m_subscription_revenue,
        SUM(d360_12m_subscription_conversion) AS d360_12m_subscription_conversions,
        SUM(d360_12m_subscription_revenue) AS d360_12m_subscription_revenue,
        SUM(d360_partner_subscription_conversion) AS d360_partner_subscription_conversions,
        SUM(d360_partner_subscription_revenue) AS d360_partner_subscription_revenue
    
    FROM user_level_aggregate
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
),

tiktok_rollup AS (
    SELECT
        date,
        network,
        campaign,
        campaign_id,
        adgroup,
        adgroup_id,
        country_code,
        country,
        COALESCE(creative_id, creative) as creative_id_coalesce_creative,
        platform,
        SUM(d0_created_account_conversions) AS d0_created_account_conversions,
        SUM(d0_free_trial_conversions) AS d0_free_trial_conversions
    FROM intermediate_backend_campaign_performance
    WHERE network like 'TikTok%'
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
),

new_tiktok_rollup_report AS (
    SELECT
        date, sum(d0_created_account_conversions) as d0_created_account_conversions_new, sum(d0_free_trial_conversions) as d0_free_trial_conversions_new
    FROM tiktok_rollup
    WHERE date >= date '2026-01-01'
    GROUP by 1 order by 1
),

old_tiktok_rollup_report AS (
    SELECT
        date, sum(d0_created_account_conversions) as d0_created_account_conversions_old, sum(d0_free_trial_conversions) as d0_free_trial_conversion_old
    FROM intermediate.backend_tiktok_campaign_performance
    WHERE date >= date '2026-01-01'
    GROUP by 1 order by 1
)

select *
FROM old_tiktok_rollup_report
JOIN new_tiktok_rollup_report using (date)
order by date