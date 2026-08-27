SELECT first_platform,
       COUNT(DISTINCT events.master_id) AS count_unverified_new_users,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Show Tracking Block Modal' THEN events.master_id END) AS count_unverified_shown_tracking_block_modal,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Data Entry' THEN events.master_id END) AS count_unverified_opened_data_entry,
       COUNT(DISTINCT CASE
                WHEN mobile_event_name = 'Exit Data Entry' AND
                     CASE WHEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points') != ''
                     THEN JSON_EXTRACT_PATH_TEXT(LOWER(event_properties), 'number of added data points')::INT END > 0
                    THEN events.master_id END) AS count_unverified_created_tracking_point,
        count_unverified_opened_data_entry::FLOAT/count_unverified_new_users AS share_unverified_opening_data_entry,
        count_unverified_created_tracking_point::FLOAT/count_unverified_new_users AS share_unverified_creating_tracking_point
FROM der.sp_users
LEFT OUTER JOIN der.events ON sp_users.master_id = events.master_id
WHERE NOT account_is_verified
AND DATEDIFF('day', first_seen, derived_tstamp) = 0
AND derived_tstamp BETWEEN CURRENT_DATE - 7 AND CURRENT_DATE - 1
AND major_app_version > 100
GROUP BY 1
ORDER BY 1
;