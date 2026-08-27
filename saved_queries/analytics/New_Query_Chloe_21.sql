WITH web_events AS (
SELECT
    events.*,
    CASE WHEN length(split(page_urlpath, '/')[2]) = 2
         THEN slice(split(page_urlpath, '/'), 3, cardinality(split(page_urlpath, '/')) - 2)
         ELSE slice(split(page_urlpath, '/'), 2, cardinality(split(page_urlpath, '/')) - 1)
         END AS page_urlpath_segments,
    CASE WHEN length(split(page_urlpath, '/')[2]) = 2
         THEN split(page_urlpath, '/')[2]
         ELSE 'en'
         END AS derived_page_locale
FROM atomic_kinesis.events
WHERE events.platform = 'web'
  AND events.event_name != 'application_error'
  AND collector_tstamp >= TIMESTAMP '2026-03-25'
),

-- the location and marketing entity schemas for link click events have a lot of duplication, hence the next four CTEs
location_entity AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY root_id ORDER BY root_tstamp) as row_number
    FROM atomic_kinesis.com_helloclue_link_click_location_entity_1
),

deduped_location_entity AS (
    SELECT * FROM location_entity WHERE row_number = 1
),

marketing_entity AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY root_id ORDER BY root_tstamp) as row_number
    FROM atomic_kinesis.com_helloclue_link_click_marketing_entity_2
),

deduped_marketing_entity AS (
    SELECT * FROM marketing_entity WHERE row_number = 1
)

SELECT
    date_trunc('hour', collector_tstamp) as dt,
    banner_type, count(1) as events
FROM web_events
LEFT JOIN atomic_kinesis.com_snowplowanalytics_snowplow_link_click_1
    ON (web_events.event_id = com_snowplowanalytics_snowplow_link_click_1.root_id
        AND web_events.collector_tstamp = com_snowplowanalytics_snowplow_link_click_1.root_tstamp)
LEFT JOIN deduped_location_entity
    ON (web_events.event_id = deduped_location_entity.root_id
        AND web_events.collector_tstamp = deduped_location_entity.root_tstamp)
LEFT JOIN deduped_marketing_entity
    ON (web_events.event_id = deduped_marketing_entity.root_id
        AND web_events.collector_tstamp = deduped_marketing_entity.root_tstamp)
where web_events.event_name = 'link_click'
and page_url like '%https://helloclue.com/'
group by 1, 2 order by 1, 2