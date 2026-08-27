WITH ios_cohort AS (
SELECT
    analytics_id,
    COUNT(*) AS count_records
FROM der.users
INNER JOIN der.sessions USING (analytics_id)
WHERE
    account_created_at BETWEEN DATE '2024-10-01' AND DATE '2024-11-01'
    AND session_start BETWEEN DATE '2025-10-01' AND DATE '2025-11-01'
    AND platform = 'ios'
GROUP BY 1
)
SELECT
    DATE_DIFF('month', DATE '2024-10-01', DATE_TRUNC('month', derived_tstamp)) AS month,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Exit Daily Check In Tracking'
        THEN session_id END) * 1.0/COUNT(DISTINCT session_id) AS daily_check_in_track_rate,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Exit Data Entry' AND navigation_context = 'daily check in'
        THEN session_id END) * 1.0/COUNT(DISTINCT session_id) AS daily_check_in_track_more_experience_rate,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Exit Data Entry' AND navigation_context = 'bottom bar'
        THEN session_id END) * 1.0/COUNT(DISTINCT session_id) AS core_tracking_from_bottom_bar_track_rate,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Exit Data Entry' AND navigation_context IN ('calendar', 'calendar sheet')
        THEN session_id END) * 1.0/COUNT(DISTINCT session_id) AS core_tracking_from_calendar_track_rate,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Exit Data Entry' AND navigation_context IN ('cycle phase feed')
        THEN session_id END) * 1.0/COUNT(DISTINCT session_id) AS core_tracking_from_cycle_phase_feed_track_rate,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Exit Multi Day Tracker' AND navigation_context LIKE '%cycle view%'
        THEN session_id END) * 1.0/COUNT(DISTINCT session_id) AS cycle_view_fast_track_rate,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Exit Multi Day Tracker' AND navigation_context LIKE '%calendar%'
        THEN session_id END) * 1.0/COUNT(DISTINCT session_id) AS calendar_fast_track_rate
FROM ios_cohort
INNER JOIN der.events USING (analytics_id)
WHERE
    derived_tstamp BETWEEN DATE '2024-10-01' AND DATE '2025-11-01'
    AND mobile_event_name IN (
        'Exit Data Entry',
        'Exit Multi Day Tracker',
        'Exit Daily Check In Tracking'
        )
GROUP BY 1
ORDER BY 1