SELECT os_type, COUNT(*)
FROM der.events
LEFT JOIN atomic_kinesis.com_snowplowanalytics_snowplow_mobile_context_1 AS sp_mobile_context
    ON events.root_id = sp_mobile_context.root_id
    AND events.collector_tstamp = sp_mobile_context.root_tstamp
    AND sp_mobile_context.root_tstamp >= DATE('2024-07-31')
WHERE DATE(events.derived_tstamp) = DATE('2024-08-31')
  AND events.schema_name != 'backend_events'
  AND events.platform IS NULL
  AND major_app_version > 100
GROUP BY 1
ORDER BY 1
LIMIT 500
;