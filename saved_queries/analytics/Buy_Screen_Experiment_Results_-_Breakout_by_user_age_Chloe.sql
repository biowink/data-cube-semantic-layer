with experiment_entry_events AS (
    SELECT
        session_id,
        JSON_EXTRACT_PATH_TEXT(event_properties, 'Experiment Group', FALSE) as experiment_group
        
    FROM der.events
    WHERE mobile_event_name = 'Buy Screen Experiment Entry'
    AND derived_tstamp >= '2023-03-09'
    GROUP BY 1, 2
)


SELECT
    CASE WHEN DATEDIFF(day, sp_users.first_seen, sessions.session_start) BETWEEN 0 AND 30 THEN 'M0'
         ELSE 'D31+'
    END AS user_group,
    
    experiment_group,
    -- DATE_TRUNC('day', session_start) as dt,
    -- COUNT(1) as sessions,
    
    COUNT(DISTINCT master_id) as users,
    -- COUNT(CASE WHEN count_view_subscription_plans > 0 THEN 1 ELSE NULL END) as sessions_viewed_buy_screen,
    -- COUNT(CASE WHEN subscription_started_transaction_id IS NOT NULL THEN 1 ELSE NULL END) as sessions_subscribed,
    COUNT(DISTINCT CASE WHEN count_view_subscription_plans > 0 THEN master_id ELSE NULL END) as users_viewed_buy_screen,
    COUNT(DISTINCT CASE WHEN subscription_started_transaction_id IS NOT NULL THEN master_id ELSE NULL END) as users_subscribed,
    
    -- ROUND(100*sessions_viewed_buy_screen::FLOAT/sessions,4) as share_session_viewed_bs,
    -- ROUND(100*sessions_subscribed::FLOAT/sessions,4) as session_cvr,
    -- ROUND(100*sessions_subscribed::FLOAT/sessions_viewed_buy_screen,4) AS session_cvr_from_bs,
    
    100*users_viewed_buy_screen::FLOAT/users as share_users_viewed_bs,
    100*users_subscribed::FLOAT/users as user_cvr,
    100*users_subscribed::FLOAT/users_viewed_buy_screen AS user_cvr_from_bs
    
FROM der.sessions
JOIN experiment_entry_events exp USING (session_id)
JOIN der.sp_users USING(master_id)
WHERE sessions.session_start >= '2023-03-09'
GROUP BY 1, 2 ORDER BY 1, 2