with contact_clue_events as (
select root_id, event_properties
FROM der.sorted_events
where derived_tstamp >= '2022-03-01'
and mobile_event_name = 'Contact Clue'

)

select
    json_extract_path_text(event_properties, 'State') as state,
    count(root_id) as events
FROM contact_clue_events
group by 1
order by 1
-- order by 3 desc