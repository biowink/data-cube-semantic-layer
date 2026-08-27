SELECT
    root_id,
    mobile_event_name,
    event_properties
FROM der.sorted_events
where derived_tstamp between '2022-07-01' and '2022-07-02'
  and mobile_event_name = 'Read Article'
limit 100