WITH conversions AS (
    SELECT
        session_id,
        device_id,
        session_start,
        ELEMENT_AT(SPLIT(ELEMENT_AT(SPLIT(first_page_url, 'gad_campaignid='), 2), '&'), 1) AS google_campaign_id,
        web_sessions.analytics_id,
        -- country_code,
        -- country_name,
        account_created_ts IS NOT NULL as account_created,
        CASE WHEN account_created_ts IS NOT NULL THEN users.account_created_at ELSE NULL END AS account_created_at,
        
        MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Free Trial'
                  AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(users.account_created_at AS DATE) 
                  THEN 1 ELSE 0 END
            ) AS d0_free_trial_conversion,
        MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
                  AND all_subscriptions_events.subscription_duration = 1
                  AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(users.account_created_at AS DATE) 
                  THEN 1 ELSE 0 END
            ) AS d0_1m_subscription_conversion,
        SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
                  AND all_subscriptions_events.subscription_duration = 1
                  AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(users.account_created_at AS DATE)
                  THEN gross_sales_euro ELSE 0 END
            ) AS d0_1m_subscription_revenue,
        MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
                  AND all_subscriptions_events.subscription_duration = 12
                  AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(users.account_created_at AS DATE)
                  THEN 1 ELSE 0 END
            ) AS d0_12m_subscription_conversion,
        SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
                  AND all_subscriptions_events.subscription_duration = 12
                  AND CAST(all_subscriptions_events.backend_created_at AS DATE) = CAST(users.account_created_at AS DATE)
                  THEN gross_sales_euro ELSE 0 END
            ) AS d0_12m_subscription_revenue,
    
        -- d7
        MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Free Trial'
                  AND DATE_DIFF('day', CAST(users.account_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
                  THEN 1 ELSE 0 END
            ) AS d7_free_trial_conversion,
        MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
                  AND all_subscriptions_events.subscription_duration = 1
                  AND DATE_DIFF('day', CAST(users.account_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
                  THEN 1 ELSE 0 END
            ) AS d7_1m_subscription_conversion,
        SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
                  AND all_subscriptions_events.subscription_duration = 1
                  AND DATE_DIFF('day', CAST(users.account_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
                  THEN gross_sales_euro ELSE 0 END
            ) AS d7_1m_subscription_revenue,
        MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
                  AND all_subscriptions_events.subscription_duration = 12
                  AND DATE_DIFF('day', CAST(users.account_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
                  THEN 1 ELSE 0 END
            ) AS d7_12m_subscription_conversion,
        MAX(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
                  AND all_subscriptions_events.subscription_duration = 12
                  AND all_subscriptions_events.is_in_intro_offer_period = TRUE
                  AND DATE_DIFF('day', CAST(users.account_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
                  THEN 1 ELSE 0 END
            ) AS d7_12m_promo_subscription_conversion,
        SUM(CASE WHEN all_subscriptions_events.subscription_type = 'Subscription Purchased'
                  AND all_subscriptions_events.subscription_duration = 12
                  AND DATE_DIFF('day', CAST(users.account_created_at AS DATE), CAST(all_subscriptions_events.backend_created_at AS DATE)) BETWEEN 0 and 7
                  THEN gross_sales_euro ELSE 0 END
            ) AS d7_12m_subscription_revenue

    FROM der.web_sessions
    LEFT JOIN der.users ON (web_sessions.analytics_id = users.analytics_id) 
    LEFT JOIN der.all_subscriptions_events 
      ON (users.analytics_id = all_subscriptions_events.analytics_id
        AND web_sessions.account_created_ts IS NOT NULL
        AND all_subscriptions_events.subscription_type IN ('Subscription Free Trial', 'Subscription Purchased')
        AND all_subscriptions_events.backend_created_at BETWEEN users.account_created_at AND users.account_created_at + INTERVAL '8' day)

    WHERE first_page_url like 'https://new.helloclue.com%' AND first_page_url like '%gad_campaignid%'
    AND session_start >= date '2025-08-01'
    
    GROUP BY 1, 2, 3, 4, 5, 6, 7
),

sessions AS (
    SELECT
        sessions.analytics_id
    FROM der.sessions
    JOIN (SELECT analytics_id, session_start FROM conversions WHERE analytics_id IS NOT NULL) AS attributed_users
      ON (sessions.analytics_id = attributed_users.analytics_id
          AND sessions.session_start >= attributed_users.session_start)
    GROUP BY 1
),

conversions_roll_up AS (
    SELECT
        DATE_TRUNC('day', session_start) AS date,
        google_campaign_id,
        COUNT(session_id) AS clicks,
        COUNT(CASE WHEN account_created THEN conversions.analytics_id ELSE NULL END) AS accounts_created,
        COUNT(sessions.analytics_id) as installs,
        
        SUM(d0_free_trial_conversion) AS d0_free_trial_conversions,
        SUM(d0_1m_subscription_conversion) AS d0_1m_subscription_conversions,
        SUM(d0_1m_subscription_revenue) AS d0_1m_subscription_revenue,
        SUM(d0_12m_subscription_conversion) AS d0_12m_subscription_conversions,
        SUM(d0_12m_subscription_revenue) AS d0_12m_subscription_revenue,
    
        SUM(d7_free_trial_conversion) AS d7_free_trial_conversions,
        SUM(d7_1m_subscription_conversion) AS d7_1m_subscription_conversions,
        SUM(d7_1m_subscription_revenue) AS d7_1m_subscription_revenue,
        SUM(d7_12m_subscription_conversion) AS d7_12m_subscription_conversions,
        SUM(d7_12m_promo_subscription_conversion) AS d7_12m_promo_subscription_conversions,
        SUM(d7_12m_subscription_revenue) AS d7_12m_subscription_revenue
        
    FROM conversions
    LEFT JOIN sessions
      ON (conversions.analytics_id = sessions.analytics_id)
    GROUP BY 1, 2
),

spend AS (
    SELECT 
        "segments.date" AS date,
        "campaign.name" AS google_campaign_name,
        CAST("campaign.id" AS VARCHAR) AS google_campaign_id,
        "campaign_budget.amount_micros"/1000000.0 as campaign_budget_amount,
        SUM("metrics.cost_micros")/1000000.0 AS cost,
        SUM("metrics.impressions") AS impressions,
        SUM("metrics.clicks") AS clicks,
        SUM("metrics.conversions") AS conversions
    FROM airbyte.google_ads_campaign
    WHERE "campaign.name" LIKE '%_Search_%'
    GROUP BY 1, 2, 3, 4
)

SELECT
    
    conversions_roll_up.date,
    conversions_roll_up.google_campaign_id,
    spend.google_campaign_name,
    spend.campaign_budget_amount,
    spend.cost,
    spend.impressions as google_reported_impressions,
    spend.clicks as google_reported_clicks,
    spend.conversions as google_reported_conversions,
    conversions_roll_up.clicks,
    conversions_roll_up.accounts_created,
    conversions_roll_up.installs,
    d0_free_trial_conversions,
    d0_1m_subscription_conversions,
    d0_1m_subscription_revenue,
    d0_12m_subscription_conversions,
    d0_12m_subscription_revenue,
    d7_free_trial_conversions,
    d7_1m_subscription_conversions,
    d7_1m_subscription_revenue,
    d7_12m_subscription_conversions,
    d7_12m_promo_subscription_conversions,
    d7_12m_subscription_revenue
    
FROM conversions_roll_up
LEFT JOIN spend
  ON (conversions_roll_up.date = spend.date 
      AND conversions_roll_up.google_campaign_id = spend.google_campaign_id)
ORDER BY 1, 2