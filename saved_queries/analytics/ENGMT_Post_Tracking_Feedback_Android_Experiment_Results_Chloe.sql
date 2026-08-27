-- did users in the test group have more tracking sessions during the experiment timeframe?

WITH raw_sessions AS (
    SELECT
        master_id,
        COUNT(DISTINCT DATE_TRUNC('day', derived_tstamp)) as sessions
    FROM der.sorted_events
    WHERE derived_tstamp >= '2022-05-19'
        AND mobile_event_name = 'Exit Data Entry'
        AND platform = 'android'
    GROUP BY 1
),

sessions AS (
    SELECT
        ab.variant_name,
        raw_sessions.master_id,
        sessions
    FROM raw_sessions
    JOIN (SELECT * FROM der.a_b_test_participation 
          WHERE test_name = 'ENGMT - Tracking feedback - Android') 
        AS ab USING(master_id) 
    ORDER BY ab.variant_name, sessions
),

quartiles AS (
    SELECT
        variant_name,
        sessions,
        PERCENTILE_CONT(0.1) WITHIN GROUP(ORDER BY sessions) OVER (PARTITION BY variant_name) AS sessions_10th,
        PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY sessions) OVER (PARTITION BY variant_name) AS sessions_q1,
        MEDIAN(sessions) OVER (PARTITION BY variant_name) AS sessions_median,
        PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY sessions) OVER (PARTITION BY variant_name) AS sessions_q3,
        PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY sessions) OVER (PARTITION BY variant_name) AS sessions_90th,
        PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY sessions) OVER (PARTITION BY variant_name) AS sessions_95th,
        PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY sessions) OVER (PARTITION BY variant_name) AS sessions_99th
    FROM sessions
)

SELECT variant_name,
       COUNT(sessions) as sample_size,
       MIN(sessions) AS sessions_min,
       AVG(sessions_q1) AS sessions_25th_pctl,
       AVG(sessions_median) AS sessions_median,
       AVG(sessions::float) as sessions_mean,
       AVG(sessions_q3) AS sessions_75th_pctl,
       MAX(sessions) AS sessions_max,
       STDDEV(sessions) as sessions_std

FROM quartiles
GROUP BY 1