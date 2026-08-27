WITH cts as (
        SELECT
            date,
            network_name,
            campaign_name,
            adgroup_name,
            creative_name,
            country_name,
            event_name,
            CASE
              WHEN event_name LIKE '%1m' THEN 1
              WHEN event_name LIKE '%6m' THEN 6
              WHEN event_name LIKE '%12m' THEN 12
              WHEN event_name LIKE '%Trial%' THEN 12
            END AS subscription_duration,
            SUM(converted_users) as sum_converted_users
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
          GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
)

SELECT event_name, subscription_duration, sum(sum_converted_users)
FROM cts
GROUP BY 1, 2
ORDER BY 2, 1