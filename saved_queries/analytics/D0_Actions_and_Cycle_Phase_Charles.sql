SELECT
    CASE
        WHEN cycle_phase = 'early follicular' THEN 'a. early follicular'
        WHEN cycle_phase = 'late follicular' THEN 'b. late follicular'
        WHEN cycle_phase = 'ovulation' THEN 'c. ovulation'
        WHEN cycle_phase = 'early luteal' THEN 'd. early luteal'
        WHEN cycle_phase = 'mid luteal' THEN 'e. mid luteal'
        WHEN cycle_phase = 'late luteal' THEN 'f. late luteal'
        WHEN user_last_birth_control_settings.type
                 IN ('combined_pill', 'vaginal_ring', 'hormonal_iud', 'implant', 'mini_pill', 'patch', 'shot')
            THEN 'g. hbc'
        ELSE 'h. missing period'
    END AS cycle_phase,
    cycle_phase_new_users.platform,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Data Entry' THEN cycle_phase_new_users.analytics_id END) * 1.0/
        COUNT(DISTINCT cycle_phase_new_users.analytics_id) AS share_open_data_entry,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Exit Data Entry' THEN cycle_phase_new_users.analytics_id END) * 1.0/
        COUNT(DISTINCT cycle_phase_new_users.analytics_id) AS share_exit_data_entry,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Content Tab' THEN cycle_phase_new_users.analytics_id END) * 1.0/
        COUNT(DISTINCT cycle_phase_new_users.analytics_id) AS share_content_tab,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Calendar' THEN cycle_phase_new_users.analytics_id END) * 1.0/
        COUNT(DISTINCT cycle_phase_new_users.analytics_id) AS share_calendar,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Analysis' THEN cycle_phase_new_users.analytics_id END) * 1.0/
        COUNT(DISTINCT cycle_phase_new_users.analytics_id) AS share_analysis,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Exit Multi Day Tracker' THEN cycle_phase_new_users.analytics_id END) * 1.0/
        COUNT(DISTINCT cycle_phase_new_users.analytics_id) AS share_multiday_tracker,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Daily Check In' THEN cycle_phase_new_users.analytics_id END) * 1.0/
        COUNT(DISTINCT cycle_phase_new_users.analytics_id) AS share_daily_check_in,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Show Cycle Phase Community Insights' THEN cycle_phase_new_users.analytics_id END) * 1.0/
        COUNT(DISTINCT cycle_phase_new_users.analytics_id) AS share_cycle_phase_feed
FROM temp.cycle_phase_new_users
INNER JOIN user_metrics.user_onboarding_funnel
    ON cycle_phase_new_users.analytics_id = user_onboarding_funnel.analytics_id
LEFT JOIN user_metrics.user_last_birth_control_settings
    ON cycle_phase_new_users.analytics_id = user_last_birth_control_settings.analytics_id
LEFT JOIN der.events
    ON cycle_phase_new_users.analytics_id = events.analytics_id
    AND DATE_DIFF('day', account_created_at, derived_tstamp) = 0
    AND derived_tstamp BETWEEN DATE '2025-07-01' AND DATE '2025-09-02'
    AND mobile_event_name IN (
        'Open Data Entry',
        'Exit Data Entry',
        'Open Calendar',
        'Open Analysis',
         'Open Daily Check In',
         'Exit Daily Check In Tracking',
         'Open Content Tab',
         'Open Multi Day Tracker',
        'Exit Multi Day Tracker',
         'Open Article',
         'Open Category Selection Screen',
         'Open Mode Picker',
         'Show Cycle Phase Community Insights'
        )
WHERE assign_onboarding_mode_mode = 'period tracking'
    AND DATE(finish_onboarding_ts) = DATE(account_created_at)
GROUP BY 1, 2
ORDER BY 1, 2
;