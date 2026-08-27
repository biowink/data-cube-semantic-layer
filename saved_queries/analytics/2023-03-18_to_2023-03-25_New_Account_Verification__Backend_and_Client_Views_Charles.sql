SELECT first_platform,
       COUNT(DISTINCT sp_users.master_id) AS count_users,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Did Authenticate Social Account'
            AND json_extract_path_text(event_properties, 'Sign Up Or Sign In') = 'sign up'
           THEN sp_users.master_id END) AS count_social_verified_client,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Email Verified'
           THEN sp_users.master_id END) AS count_email_verified_client,
    count_social_verified_client + count_email_verified_client AS count_total_verified_client,
       COUNT(DISTINCT CASE WHEN account_is_verified THEN sp_users.master_id END) AS count_total_verified_backend,
        count_total_verified_backend::FLOAT/count_users AS share_verified_backend
FROM der.sp_users
LEFT JOIN der.events ON sp_users.master_id = events.master_id
    AND derived_tstamp >= '2023-03-18' AND mobile_event_name IN ('Did Authenticate Social Account', 'Email Verified')
WHERE first_seen BETWEEN '2023-03-18' AND '2023-03-25'
    AND first_platform IN ('ios', 'android')
    AND SPLIT_PART(first_app_version, '.', 1)::INT >= 101
GROUP BY 1
ORDER BY 1
;