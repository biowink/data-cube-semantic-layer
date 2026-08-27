      WITH
        campaign_cost AS (
          SELECT
            date,
            network_name,
            campaign_name,
            adgroup_name,
            CASE WHEN network_name = 'Google Ads ACI' THEN 'unknown' ELSE creative_name END AS creative,
            SUM(cost) AS total_cost,
            SUM(installs) AS total_installs
          FROM
            der.adjust_deliverables
          WHERE
            network_name NOT IN ('Retargeting - Clue Plus - Website', 'Clue account - Website', 'Clue App',
              'TikTok (iOS - Mobvista)', 'GDPR Forgets Before Install', 'Partners', 'Jesse Pinho''s Dev Sandbox',
              'Twitter', 'Imported Devices', 'agusanion', 'Pinterest - US', 'Pinterest New')
            AND date >= '2022-07-01'
          GROUP BY
            date,
            network_name,
            campaign_name,
            adgroup_name,
            creative
        ),

        cohort AS (
          SELECT
            date,
            network_name,
            campaign_name,
            adgroup_name,
            creative_name,
            country_name,
            CASE
              WHEN event_name LIKE '%1m' THEN 1
              WHEN event_name LIKE '%6m' THEN 6
              WHEN event_name LIKE '%12m' THEN 12
              WHEN event_name LIKE '%Trial%' THEN 12
            END AS subscription_duration,
            converted_users
          FROM
            import.adjust_cohorts_users
            LEFT JOIN import.adjust_events_name ON events = event
            LEFT JOIN static.countries ON UPPER(country) = iso_alpha_2
          WHERE
            event_name NOT IN ('Paid Clue Plus 12m','Start Free Trial CBC','Second Session Started',
              'Renewed CBC 1m','Renewed CBC 12m','Paid CBC 1m','Paid CBC 12m','Did Create Account',
              'Renewed Clue Plus 1m','Renewed Clue Plus 6m','Renewed Clue Plus 12m')
            AND network_name NOT IN ('Retargeting - Clue Plus - Website', 'Clue account - Website', 'Clue App',
              'TikTok (iOS - Mobvista)', 'GDPR Forgets Before Install', 'Partners', 'Jesse Pinho''s Dev Sandbox',
              'Twitter', 'Imported Devices', 'agusanion', 'Pinterest - US', 'Pinterest New')
          AND event_name IS NOT NULL
          AND period = 0
        ),

        cumulative_revenue AS (
          SELECT
            date,
            network_name,
            campaign_name,
            adgroup_name,
            creative_name,
            country_name,
            CASE
              WHEN event_name LIKE '%1m' THEN 1
              WHEN event_name LIKE '%6m' THEN 6
              WHEN event_name LIKE '%12m' THEN 12
              WHEN event_name LIKE '%Trial%' THEN 12
            END AS subscription_duration,
            SUM(revenue) AS revenue
            -- Revenue to date can be only calculated to maximum 120 days from D0
          FROM import.adjust_cohorts_users
            LEFT JOIN import.adjust_events_name ON events = event
            LEFT JOIN static.countries ON UPPER(country) = iso_alpha_2
          WHERE (events NOT IN ('8h6kr9', 'ptn46p') OR (period > 0 AND events IN ('8h6kr9', 'ptn46p')))
            AND event_name NOT IN ('Start Free Trial CBC','Second Session Started',
              'Renewed CBC 1m','Renewed CBC 12m','Paid CBC 1m','Paid CBC 12m','Did Create Account',
              'Renewed Clue Plus 1m','Renewed Clue Plus 6m','Renewed Clue Plus 12m')
            AND network_name NOT IN ('Retargeting - Clue Plus - Website', 'Clue account - Website', 'Clue App',
              'TikTok (iOS - Mobvista)', 'GDPR Forgets Before Install', 'Partners', 'Jesse Pinho''s Dev Sandbox',
              'Twitter', 'Imported Devices', 'agusanion', 'Pinterest - US', 'Pinterest New')
            AND events IS NOT NULL
            AND event_name IS NOT NULL
          GROUP BY
            date,
            network_name,
            campaign_name,
            adgroup_name,
            creative_name,
            country_name,
            subscription_duration
        ),

        promo_share AS (
          SELECT
            DATE_TRUNC('day', backend_created_at) as date,
            country,
            subscription_duration,
            COUNT(CASE WHEN is_in_intro_offer_period is TRUE AND platform = 'ANDROID'
                       THEN subscription_id ELSE NULL END)::float
                    / COUNT(subscription_id)
              AS android_promo_ratio,
            COUNT(CASE WHEN is_in_intro_offer_period is TRUE AND platform = 'IOS'
                       THEN subscription_id ELSE NULL END)::float
                    / COUNT(subscription_id)
              AS ios_promo_ratio,
            COUNT(CASE WHEN is_in_intro_offer_period is FALSE AND platform = 'ANDROID'
                       THEN subscription_id ELSE NULL END)::float
                    / COUNT(subscription_id)
              AS android_non_promo_ratio,
            COUNT(CASE WHEN is_in_intro_offer_period is FALSE AND platform = 'IOS'
                       THEN subscription_id ELSE NULL END)::float
                    / COUNT(subscription_id)
              AS ios_non_promo_ratio
          FROM der.subscriptions_events
          WHERE subscription_type = 'Subscription Purchased'
          GROUP BY 1, 2, 3
        ),

        market_promo_share AS (
          SELECT
            DATE_TRUNC('day', backend_created_at) as date,
            market,
            subscription_duration,
            COUNT(CASE WHEN is_in_intro_offer_period is TRUE AND platform = 'ANDROID'
                       THEN subscription_id ELSE NULL END)::float
                    / COUNT(subscription_id)
              AS android_promo_ratio,
            COUNT(CASE WHEN is_in_intro_offer_period is TRUE AND platform = 'IOS'
                       THEN subscription_id ELSE NULL END)::float
                    / COUNT(subscription_id)
              AS ios_promo_ratio,
            COUNT(CASE WHEN is_in_intro_offer_period is FALSE AND platform = 'ANDROID'
                       THEN subscription_id ELSE NULL END)::float
                    / COUNT(subscription_id)
              AS android_non_promo_ratio,
            COUNT(CASE WHEN is_in_intro_offer_period is FALSE AND platform = 'IOS'
                       THEN subscription_id ELSE NULL END)::float
                    / COUNT(subscription_id)
              AS ios_non_promo_ratio
          FROM der.subscriptions_events
          JOIN intermediate.market_mapping USING (country)
          WHERE subscription_type = 'Subscription Purchased'
          GROUP BY 1, 2, 3
        ),

        ltv_filter AS (
          SELECT
            subscription_duration,
            MAX(retention_curve) AS max_retention_curve,
            MAX(created_execution_date) AS max_created_execution_date
          FROM der.ltv_with_promo_per_country
          GROUP BY subscription_duration
        ),

        year_three_ltv AS (
          SELECT
            ltv.subscription_duration,
            country,
            market,
            MAX(CASE WHEN is_in_intro_offer_period is TRUE AND platform = 'ANDROID'
                     THEN ltv ELSE NULL END)
              AS android_promo_ltv,
            MAX(CASE WHEN is_in_intro_offer_period is TRUE AND platform = 'IOS'
                     THEN ltv ELSE NULL END)
              AS ios_promo_ltv,
            MAX(CASE WHEN is_in_intro_offer_period is FALSE AND platform = 'ANDROID'
                     THEN ltv ELSE NULL END)
              AS android_non_promo_ltv,
            MAX(CASE WHEN is_in_intro_offer_period is FALSE AND platform = 'IOS'
                     THEN ltv ELSE NULL END)
              AS ios_non_promo_ltv
          FROM der.ltv_with_promo_per_country ltv
          JOIN ltv_filter ON
                  ltv.subscription_duration = ltv_filter.subscription_duration
                  AND ltv.retention_curve = ltv_filter.max_retention_curve
                  AND ltv.created_execution_date = ltv_filter.max_created_execution_date
          JOIN intermediate.market_mapping USING(country)
          GROUP BY ltv.subscription_duration, country, market
        ),

        latest_ccm AS (
          SELECT
            country,
            subscription_duration,
            ccm
          FROM
            der.ccm_per_country
          WHERE month_cohort >= DATE_TRUNC('month', CURRENT_DATE)::DATE - INTERVAL '13 months'
        ),

        global_ccm AS (
          SELECT
            subscription_duration,
            ccm
          FROM
            der.ccm
          WHERE month_cohort >= DATE_TRUNC('month', CURRENT_DATE)::DATE - INTERVAL '13 months'
        ),

        predicted_d360_users AS (
          SELECT
            cohort.date,
            network_name,
            campaign_name,
            adgroup_name,
            CASE WHEN network_name = 'Google Ads ACI' THEN 'unknown' ELSE creative_name END AS creative,
            SUM(converted_users) AS d0_subscribers,
            SUM(revenue) AS revenue_to_date,

            -- TODO: Turn the average into a weighted average. Shouldn't be a big deal for now as most
            --       ccm are pretty similar.


            d0_subscribers * 1.1 * NVL(AVG(latest_ccm.ccm), AVG(global_ccm.ccm)) AS predicted_d360_paying_users,

            SUM(converted_users *
                            ((android_promo_ltv * NVL(promo_share.android_promo_ratio, market_promo_share.android_promo_ratio))
                               + (ios_promo_ltv * NVL(promo_share.ios_promo_ratio, market_promo_share.ios_promo_ratio))
                               + (android_non_promo_ltv * NVL(promo_share.android_non_promo_ratio, market_promo_share.android_non_promo_ratio))
                               + (ios_non_promo_ltv * NVL(promo_share.ios_non_promo_ratio, market_promo_share.ios_non_promo_ratio))
                            )
                ) * 1.1 * NVL(AVG(latest_ccm.ccm), AVG(global_ccm.ccm))
              AS predicted_d360_times_ltv

          FROM
            cohort
            LEFT JOIN cumulative_revenue
              USING (date, network_name, campaign_name, adgroup_name, creative_name, country_name, subscription_duration)
            LEFT JOIN year_three_ltv ON
              cohort.subscription_duration = year_three_ltv.subscription_duration
              AND cohort.country_name::TEXT = year_three_ltv.country::TEXT
            LEFT JOIN latest_ccm ON
              cohort.subscription_duration = latest_ccm.subscription_duration
              AND cohort.country_name::TEXT = latest_ccm.country::TEXT
            LEFT JOIN global_ccm ON
              cohort.subscription_duration = global_ccm.subscription_duration
            LEFT JOIN promo_share ON
              cohort.date = promo_share.date
              AND cohort.subscription_duration = promo_share.subscription_duration
              AND cohort.country_name::TEXT = promo_share.country::TEXT
            LEFT JOIN market_promo_share ON
              cohort.date = market_promo_share.date
              AND cohort.subscription_duration = market_promo_share.subscription_duration
              AND year_three_ltv.market = market_promo_share.market
          GROUP BY
            cohort.date,
            network_name,
            campaign_name,
            adgroup_name,
            creative
          )

        SELECT
          DATE_TRUNC('week', date) AS event_date,
          network_name,
          campaign_name,
          adgroup_name,
          creative AS creative_name,
          SUM(total_cost) AS cost,
          SUM(total_installs) AS installs,
          SUM(revenue_to_date) AS revenue_to_date,
          SUM(d0_subscribers) AS d0_subscribers,
          SUM(predicted_d360_paying_users) AS predicted_d360_paying_users,
          SUM(predicted_d360_times_ltv) AS predicted_d360_times_ltv,
          ROW_NUMBER() OVER(ORDER BY event_date) AS prim_key
        FROM
          campaign_cost
          FULL OUTER JOIN predicted_d360_users USING (date, network_name, campaign_name, adgroup_name, creative)
        WHERE event_date >= '2022-07-15'
        GROUP BY
          event_date,
          network_name,
          campaign_name,
          adgroup_name,
          creative
          
      ;;