select
    root_id,
    event_properties
FROM der.sorted_events
where derived_tstamp between '2022-12-18' and '2022-12-19'
  and right(event_properties, 1) != '}'