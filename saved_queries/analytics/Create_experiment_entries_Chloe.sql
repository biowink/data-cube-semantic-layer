DROP TABLE temp.enter_experiment_events;

CREATE TABLE temp.enter_experiment_events AS (
SELECT
    root_id,
    events.master_id,
    events.analytics_id,
    events.sp_device_id,
    session_id,
    derived_tstamp,
    mobile_event_name,
    event_properties,
    -- https://biowink.atlassian.net/wiki/spaces/DATA/pages/3850174476/A+B+Test+Instrumentation
    NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'experiment_name', FALSE),'') AS experiment_name,
    NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'variant_id', FALSE),'')::INTEGER AS variant_id,
    NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'variant_name', FALSE),'') AS variant_name,
    NULLIF(JSON_EXTRACT_PATH_TEXT(event_properties, 'experiment_version', FALSE),'')::INTEGER AS experiment_version,
    platform,
    product_tier,
    country_code
FROM der.events
WHERE mobile_event_name = 'Enter Experiment'
  AND derived_tstamp between '2023-05-13' and '2023-05-22'
)
;

WITH first_entry AS (
    SELECT
        master_id,
        experiment_name,
        variant_id,
        experiment_version,
        MIN(derived_tstamp) AS first_tstamp
    FROM temp.enter_experiment_events
    WHERE experiment_name != '2304_ios_strama_60eur_price' OR derived_tstamp >= '2023-05-16 16:00:00'
    GROUP BY 1, 2, 3, 4
),

tab AS (
SELECT
    e.*--,
    -- sp_users.first_seen
FROM temp.enter_experiment_events e
JOIN first_entry f ON (e.master_id = f.master_id 
                        AND e.experiment_name = f.experiment_name
                        AND e.variant_id = f.variant_id
                        AND COALESCE(e.experiment_version::varchar,'') = COALESCE(e.experiment_version::varchar,'')
                        AND e.derived_tstamp = f.first_tstamp)
-- JOIN der.sp_users on (e.master_id = sp_users.master_id)
)

select count(1) from tab;