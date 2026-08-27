-- ARPPU (Paid ARPU) (revenue)
WITH
  __rawExperiment as (
    SELECT
      master_id as master_id,
      derived_tstamp as timestamp,
      JSON_EXTRACT_PATH_TEXT(event_properties, 'experiment_name', FALSE) as experiment_id,
      JSON_EXTRACT_PATH_TEXT(event_properties, 'variant_id', FALSE) as variation_id,
      CASE
        WHEN DATEDIFF(day, sp_users.first_seen, events.derived_tstamp) <= 0 THEN 'D0'
        ELSE 'D60+'
      END AS user_age
    FROM
      der.events
      JOIN der.sp_users USING (master_id)
    WHERE
      mobile_event_name = 'Enter Experiment'
      AND experiment_id = '2304_ios_strama_60eur_price'
      AND derived_tstamp >= '2023-05-11'
      AND (
        DATEDIFF(day, sp_users.first_seen, events.derived_tstamp) = 0
        --OR DATEDIFF(day, sp_users.first_seen, events.derived_tstamp) >= 60
      )
  ),
  __experiment as ( -- Viewed Experiment
    SELECT
      e.master_id as master_id,
      cast(e.variation_id as varchar) as variation,
      e.timestamp as timestamp,
      e.timestamp as conversion_start,
      e.timestamp + INTERVAL '168 hours' as conversion_end
    FROM
      __rawExperiment e
    WHERE
      e.experiment_id = '2304_ios_strama_60eur_price'
      AND e.timestamp >= '2023-05-16 16:00:00'
      AND e.timestamp <= '2023-05-28 00:00:00'
  ),
  __metric as ( -- Metric (ARPPU (Paid ARPU))
    SELECT
      master_id as master_id,
      m.value as value,
      m.timestamp as timestamp,
      m.timestamp as conversion_start,
      m.timestamp as conversion_end
    FROM
      (
        SELECT
          master_id,
          started_at AS timestamp,
          initial_price_paid_euro AS value
        FROM
          der.subscription_history
        WHERE
          started_at <= CURRENT_DATE - '7 days'::INTERVAL
          AND is_purchased IS TRUE
      ) m
    WHERE
      m.timestamp >= '2023-05-16 16:00:00'
      AND m.timestamp <= '2023-06-11 00:00:00'
  ),
  __denominator0 as ( -- Metric (Paid Conversion Rate)
    SELECT
      master_id as master_id,
      1 as value,
      m.timestamp as timestamp,
      m.timestamp as conversion_start,
      m.timestamp + INTERVAL '168 hours' as conversion_end
    FROM
      (
        -- SELECT
        --     master_id,
        --     started_at AS timestamp
        -- FROM der.subscription_history
        -- WHERE started_at <= CURRENT_DATE - '7 days'::INTERVAL
        --   AND is_purchased IS TRUE
        WITH
          most_recent_run AS (
            SELECT
              max(created_execution_date) AS most_recent_run_date
            FROM
              models.segmented_ltv
          ),
          ltv AS (
            SELECT
              subscription_duration,
              is_in_intro_offer_period,
              SUM(gross_price * sample_weight) / SUM(sample_weight) AS gross_price,
              SUM(ltv * sample_weight) / SUM(sample_weight) AS ltv
            FROM
              models.segmented_ltv
              JOIN most_recent_run ON (
                segmented_ltv.created_execution_date = most_recent_run.most_recent_run_date
              )
            WHERE
              is_total_ltv IS TRUE
              AND subscription_duration != 6
            GROUP BY
              1,
              2
          )
        SELECT
          master_id,
          started_at AS timestamp
        FROM
          der.subscription_history
          LEFT JOIN ltv ON (
            subscription_history.subscription_duration = ltv.subscription_duration
            AND subscription_history.started_in_intro_offer_period = ltv.is_in_intro_offer_period
          )
        WHERE
          started_at <= CURRENT_DATE - '7 days'::INTERVAL
          AND is_purchased IS TRUE
      ) m
    WHERE
      m.timestamp >= '2023-05-16 16:00:00'
      AND m.timestamp <= '2023-06-11 00:00:00'
  ),
  __denominatorUsers as (
    SELECT
      initial.master_id,
      t0.conversion_start as conversion_start,
      t0.conversion_end as conversion_end
    FROM
      __experiment initial
      JOIN __denominator0 t0 ON (t0.master_id = initial.master_id)
    WHERE
      t0.timestamp >= initial.conversion_start
      AND t0.timestamp <= initial.conversion_end
  ),
  __distinctUsers as (
    -- One row per user
    SELECT
      e.master_id as master_id,
      cast('All' as varchar) as dimension,
      (
        CASE
          WHEN count(distinct e.variation) > 1 THEN '__multiple__'
          ELSE max(e.variation)
        END
      ) as variation,
      MIN(du.conversion_start) as conversion_start,
      MIN(du.conversion_end) as conversion_end
    FROM
      __experiment e
      JOIN __denominatorUsers du ON (du.master_id = e.master_id)
    GROUP BY
      e.master_id
  ),
  __userMetric as (
    -- Add in the aggregate metric value for each user
    SELECT
      d.variation,
      d.dimension,
      d.master_id,
      sp_users.first_country_name as country,
      SUM(m.value) as value
    FROM
      __distinctUsers d
      JOIN __metric m ON (m.master_id = d.master_id)
      JOIN der.sp_users ON (d.master_id = sp_users.master_id)
    WHERE
      m.timestamp >= d.conversion_start
      AND m.timestamp <= d.conversion_end
    GROUP BY
      d.variation,
      d.dimension,
      d.master_id,
      country
  )
  select 
    country,
    CASE WHEN value < 15 THEN '1m' else '12m' end as sub_type,
    -- round(value,0), variation, count(1)
    variation, avg(value), count(1)
    from __userMetric
    -- where country = 'France'
    group by 1, 2, 3
    order by 1, 2, 3 desc
    
    