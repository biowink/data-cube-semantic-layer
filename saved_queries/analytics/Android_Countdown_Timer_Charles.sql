WITH
  __rawExperiment AS (
    SELECT
      analytics_id,
      derived_tstamp as timestamp,
      JSON_EXTRACT_SCALAR(event_properties, '$.experiment_name') as experiment_id,
      JSON_EXTRACT_SCALAR(event_properties, '$.variant_id') as variation_id,
      CASE
        WHEN DATE_DIFF(
          'hour',
          clue_users.backend_created_at,
          events.derived_tstamp
        ) <= 24 THEN 'D0'
        ELSE 'D1+'
      END AS user_age,
      CASE
        WHEN DATE_DIFF(
          'hour',
          clue_users.backend_created_at,
          events.derived_tstamp
        ) <= 720 THEN 'D30'
        ELSE 'D31+'
      END AS user_age_v2
    FROM
      der.events
      INNER JOIN core.clue_users USING (analytics_id)
    WHERE
      mobile_event_name = 'Enter Experiment'
      AND derived_tstamp >= DATE('2024-06-01')
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
      e.experiment_id = 'countdown_timer_length_android'
      AND e.timestamp >= from_iso8601_timestamp('2026-05-17T01:10:00.000Z')
      AND e.timestamp <= from_iso8601_timestamp('2026-06-01T06:02:56.469Z')
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
  __metric as ( -- Metric (Conversion Rate - Promotion Purchases, 30-Day Window)
    SELECT
      analytics_id as analytics_id,
      1 as value,
      m.timestamp as timestamp
    FROM
      (
        SELECT
          analytics_id,
          backend_created_at AS timestamp
        FROM
          der.mobile_subscriptions_events
        WHERE
          subscription_duration = 12
          AND subscription_type = 'Subscription Purchased'
          AND is_in_intro_offer_period
      ) m
    WHERE
      m.timestamp >= from_iso8601_timestamp('2026-05-17T01:10:00.000Z')
      AND m.timestamp <= from_iso8601_timestamp('2026-07-01T06:02:56.469Z')
  ),
  __userMetricJoin as (
    SELECT
      d.variation AS variation,
      d.dimension AS dimension,
      d.analytics_id AS analytics_id,
      m.timestamp,
      (
        CASE
          WHEN m.timestamp >= d.timestamp
          AND m.timestamp <= d.timestamp + INTERVAL '720' hour THEN m.value
          ELSE NULL
        END
      ) as value
    FROM
      __distinctUsers d
      LEFT JOIN __metric m ON (m.analytics_id = d.analytics_id)
  )
SELECT
    variation,
    CASE
        WHEN timestamp < TIMESTAMP '2026-05-27 11:00:00.000000' THEN '1. >48h'
        WHEN timestamp < TIMESTAMP '2026-05-28 11:00:00.000000' THEN '2. 24-48h'
        ELSE '3. <24h'
    END as time_period,
    SUM(value) AS conversions
FROM __userMetricJoin
WHERE timestamp BETWEEN TIMESTAMP '2026-05-24 16:00:00.000000' AND TIMESTAMP '2026-05-29 11:00:00.000000'
GROUP BY 1, 2
ORDER BY 1, 2
;