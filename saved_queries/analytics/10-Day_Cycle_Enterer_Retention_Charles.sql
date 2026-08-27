    SELECT cycle_lengths.platform,
           DATE_TRUNC('month', account_created_at) AS week,
           COUNT(DISTINCT cycle_lengths.analytics_id) AS count_users,
           COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT cycle_lengths.analytics_id) AS d1_retention
    FROM (SELECT
        user_onboarding_funnel.analytics_id,
        derived_tstamp,
        user_onboarding_funnel.platform,
        user_onboarding_funnel.did_create_account_ts AS account_created_at,
        JSON_EXTRACT_SCALAR(event_properties, '$["Average Cycle"]') AS average_cycle_length,
        ROW_NUMBER() OVER (PARTITION BY user_onboarding_funnel.analytics_id ORDER BY derived_tstamp DESC) AS rnk
    FROM
        der.events
        INNER JOIN user_metrics.user_onboarding_funnel USING (sp_device_id)
    WHERE
        mobile_event_name = 'Select Average Cycle'
        AND events.major_app_version >= 100
        AND derived_tstamp >= DATE '2024-01-01'
        AND did_create_account_ts >= DATE '2024-01-01'
        AND did_create_account_ts < DATE '2025-02-15'
    ) cycle_lengths
    LEFT JOIN der.sessions ON cycle_lengths.analytics_id = sessions.analytics_id
        AND DATE_DIFF('day', account_created_at, session_start) BETWEEN 7 AND 14
        AND session_start >= DATE '2024-01-01'
    WHERE rnk = 1 AND average_cycle_length = '10'
    GROUP BY 1, 2
    ORDER BY 1, 2