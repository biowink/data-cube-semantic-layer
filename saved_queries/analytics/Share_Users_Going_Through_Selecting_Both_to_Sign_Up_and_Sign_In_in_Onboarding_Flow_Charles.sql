WITH events_agg AS (
SELECT funnel.sp_device_id,
       funnel.major_app_version,
       funnel.platform,
       MAX(CASE WHEN mobile_event_name = 'Did Sign In' THEN 1 ELSE 0 END) AS did_sign_in,
       MAX(CASE WHEN mobile_event_name = 'Select Sign In Method' THEN 1 ELSE 0 END) AS did_select_sign_in_method,
       MAX(CASE WHEN mobile_event_name = 'Did Create Account' THEN 1 ELSE 0 END) AS did_create_account,
       MAX(CASE WHEN mobile_event_name = 'Select Sign Up Or Sign In'
           AND JSON_EXTRACT_SCALAR(event_properties, '$["Sign Up Or Sign In"]') = 'sign in' THEN 1 ELSE 0 END) AS did_click_sign_in,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Select Sign Up Or Sign In'
           THEN NULLIF(JSON_EXTRACT_SCALAR(event_properties, '$["Sign Up Or Sign In"]'), '')
        END) AS count_attempts
FROM user_metrics.user_onboarding_funnel funnel
LEFT JOIN der.events ON funnel.sp_device_id = events.sp_device_id AND
                        DATE(show_welcome_screen_ts) = DATE(derived_tstamp)
                        AND derived_tstamp >= DATE('2024-06-01')
                        AND mobile_event_name IN ('Did Sign In', 'Select Sign In Method',
                                                   'Did Create Account',  'Select Sign Up Or Sign In')
WHERE show_welcome_screen_ts >= DATE('2024-06-01')
GROUP BY 1, 2, 3
    )
SELECT platform,
       major_app_version,
       COUNT(*) AS count_users,
       AVG(did_sign_in * 1.0) AS share_did_sign_in,
       AVG(did_select_sign_in_method * 1.0) AS share_did_select_sign_in_method,
       AVG(did_create_account * 1.0) AS share_did_create_account,
       AVG(did_click_sign_in * 1.0) AS share_did_click_sign_in,
       AVG(CASE WHEN count_attempts = 2 THEN 1.0 ELSE 0 END) AS did_have_multiple_attempts
FROM events_agg
GROUP BY 1, 2
HAVING COUNT(*) > 5000
ORDER BY 1, 2