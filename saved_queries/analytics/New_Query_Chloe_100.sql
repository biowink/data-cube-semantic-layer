WITH cohort AS (
SELECT
    date,
    network_name,
    campaign_name,
    adgroup_name,
    creative_name,
    country_name,
    revenue,
    revenue::float/converted_users as revenue_per_user,
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

year_three_ltv AS (
  SELECT DISTINCT
    subscription_duration,
    country,
    FIRST_VALUE(gross_price) OVER (
      PARTITION BY subscription_duration
      ORDER BY retention_curve, created_execution_date
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS price,
    LAST_VALUE(ltv) OVER (
      PARTITION BY subscription_duration
      ORDER BY retention_curve, created_execution_date
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS ltv
  FROM
    der.ltv_per_country
  WHERE retention_curve != 0
)

SELECT *,

ROUND(revenue_per_user) as rounded_adjust_price,
ROUND(price) as rounded_backend_price

FROM cohort
LEFT JOIN year_three_ltv ON
  cohort.subscription_duration = year_three_ltv.subscription_duration
  AND cohort.country_name::TEXT = year_three_ltv.country::TEXT

-- select * FROM import.adjust_cohorts_users 
-- LEFT JOIN import.adjust_events_name ON events = event
-- WHERE
-- event_name NOT IN ('Paid Clue Plus 12m','Start Free Trial CBC','Second Session Started',
--   'Renewed CBC 1m','Renewed CBC 12m','Paid CBC 1m','Paid CBC 12m','Did Create Account',
--   'Renewed Clue Plus 1m','Renewed Clue Plus 6m','Renewed Clue Plus 12m')
-- AND network_name NOT IN ('Retargeting - Clue Plus - Website', 'Clue account - Website', 'Clue App',
--   'TikTok (iOS - Mobvista)', 'GDPR Forgets Before Install', 'Partners', 'Jesse Pinho''s Dev Sandbox',
--   'Twitter', 'Imported Devices', 'agusanion', 'Pinterest - US', 'Pinterest New')
-- AND event_name IS NOT NULL
-- AND period = 0
-- LIMIT 10;