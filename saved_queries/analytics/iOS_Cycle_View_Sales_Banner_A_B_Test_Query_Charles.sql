WITH
  __rawExperiment AS (
    SELECT
      analytics_id,
      derived_tstamp as timestamp,
      major_app_version,
      JSON_EXTRACT_PATH_TEXT(event_properties, 'experiment_name', FALSE) as experiment_id,
      JSON_EXTRACT_PATH_TEXT(event_properties, 'variant_id', FALSE) as variation_id,
      CASE
        WHEN DATEDIFF(
          hour,
          users.account_created_at,
          events.derived_tstamp
        ) <= 24 THEN 'D0'
        ELSE 'D1+'
      END AS user_age
    FROM
      der.events
      JOIN der.users USING (analytics_id)
    WHERE
      mobile_event_name = 'Enter Experiment'
      AND derived_tstamp >= '2024-08-04 12:00:00'
      AND major_app_version >= 178
  ),
  __experimentExposures AS (
    -- Viewed Experiment
    SELECT
      e.analytics_id as analytics_id,
      cast(e.variation_id as varchar) as variation,
      e.timestamp as timestamp
    FROM
      __rawExperiment e
    WHERE
      e.experiment_id = '2405_cycle_view_sale_banner_ios'
      AND e.timestamp >= '2024-08-04 12:00:00'
  ),
  __experimentUnits AS (
    -- One row per user
    SELECT
      e.analytics_id AS analytics_id,
      (
        CASE
          WHEN count(distinct e.variation) > 1 THEN '__multiple__'
          ELSE max(e.variation)
        END
      ) AS variation,
      MIN(e.timestamp) AS first_exposure_timestamp
    FROM
      __experimentExposures e
    GROUP BY
      e.analytics_id
  ),
  __distinctUsers AS (
    SELECT
      analytics_id,
      cast('All' as varchar) AS dimension,
      variation,
      first_exposure_timestamp AS timestamp,
      date_trunc('day', first_exposure_timestamp) AS first_exposure_date
    FROM
      __experimentUnits
  ),
  __metric as ( -- Metric (Conversion Rate)
    SELECT
      analytics_id as analytics_id,
      1 as value,
      m.timestamp as timestamp
    FROM
      (
        SELECT
          analytics_id,
          started_at AS timestamp
        FROM
          der.subscription_history
      ) m
    WHERE
      m.timestamp >= '2024-08-04 12:00:00'
  ),
  __userMetricJoin as (
    SELECT
      d.variation AS variation,
      d.dimension AS dimension,
      d.analytics_id AS analytics_id,
      (
        CASE
          WHEN m.timestamp >= d.timestamp THEN m.value
          ELSE NULL
        END
      ) as value
    FROM
      __distinctUsers d
      LEFT JOIN __metric m ON (m.analytics_id = d.analytics_id)
  ),
  __userMetricAgg as (
    -- Add in the aggregate metric value for each user
    SELECT
      umj.variation AS variation,
      umj.dimension AS dimension,
      umj.analytics_id,
      MAX(COALESCE(value, 0)) as value
    FROM
      __userMetricJoin umj
    GROUP BY
      umj.variation,
      umj.dimension,
      umj.analytics_id
  )
  -- One row per variation/dimension with aggregations
SELECT
  m.variation AS variation,
  m.dimension AS dimension,
  COUNT(*) AS users,
  SUM(COALESCE(m.value, 0)) AS conversions
FROM
  __userMetricAgg m
GROUP BY
  m.variation,
  m.dimension
ORDER BY m.variation
;