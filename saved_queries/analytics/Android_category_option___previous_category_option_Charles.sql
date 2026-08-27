select
    json_extract_path_text(event_properties, 'Category Option', false) as category_option,
    json_extract_path_text(event_properties, 'Previous Category Option', false) as previous_category_option,
    count(1) as exit_option_modal_event_count
from der.events
where derived_tstamp between '2023-04-01' and '2023-04-05'
and mobile_event_name = 'Exit Option Modal' AND platform = 'android'
group by 1, 2
order by 3 desc