SELECT
    DATE_TRUNC('day', root_tstamp) AS dt,
    COUNT(1) AS events
FROM atomic_kinesis.com_helloclue_backend_events_1
WHERE com_helloclue_backend_events_1.event_name = 'computed_cycles_updated'
GROUP BY 1 ORDER BY 1