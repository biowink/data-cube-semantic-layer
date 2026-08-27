WITH numbered_event_1 AS (
            SELECT
              sp_device_id,
              platform,
              market,
              country,
              major_app_version,
              minor_app_version,
              app_version,
              derived_tstamp AS event_1_time,
              ROW_NUMBER() OVER(PARTITION BY sp_device_id ORDER BY derived_tstamp)
            FROM der.events
            LEFT JOIN static.market_mapping
              ON events.country_name = market_mapping.country
            WHERE derived_tstamp between current_date - '{{days}} days'::interval - '1 day'::interval AND current_date - '1 day'::interval
              AND mobile_event_name = 'Show Welcome Screen'
         ),
         event_1 AS (
            SELECT sp_device_id, platform, market, country, major_app_version, minor_app_version, app_version, event_1_time
            FROM numbered_event_1
            WHERE row_number = 1
         ),
         
event_2 AS (
    SELECT event_1.*, MIN(events.derived_tstamp) AS event_2_time
    FROM event_1
    LEFT JOIN (
        SELECT sp_device_id, derived_tstamp
        FROM der.events
        WHERE derived_tstamp between current_date - '{{days}} days'::interval - '1 day'::interval AND current_date
          AND mobile_event_name = 'Subscription Started'
          AND JSON_EXTRACT_PATH_TEXT(event_properties, 'Navigation Context', FALSE) = 'onboarding'
      ) AS events
      ON event_1.sp_device_id = events.sp_device_id
      AND events.derived_tstamp BETWEEN event_1.event_1_time - INTERVAL '1 second'
          AND event_1.event_1_time + '1 hour'::interval
    GROUP BY event_1.sp_device_id, platform, market, country, major_app_version, minor_app_version, app_version,
      event_1_time
),
sub as (
SELECT
    platform,
    app_version,
    COUNT(sp_device_id) as users,
    COUNT(event_2_time) as converted_users,
    100*converted_users::float/users as conversion_rate
FROM event_2
GROUP BY 1, 2
ORDER BY 1, 2
)

select * from sub where users >= 10000



