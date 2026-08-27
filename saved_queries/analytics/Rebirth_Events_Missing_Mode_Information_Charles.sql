SELECT AVG(CASE WHEN events.mode IS NULL THEN 1::FLOAT ELSE 0 END) AS missing_mode,
       AVG(CASE WHEN events.event_properties IS NULL THEN 1::FLOAT ELSE 0 END) AS missing_event_properties
FROM der.events
WHERE platform = 'ios' AND derived_tstamp >= CURRENT_DATE - 6
  AND SPLIT_PART(app_version, '.', 1)::INT >= 100
;