SELECT start::DATE AS date,
       sp_sessions.platform,
       COUNT(DISTINCT sp_sessions.master_id) AS existing_active_users,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'View Subscription Plans' AND navigation_context NOT ILIKE '%onboarding%' 
        THEN events.root_id END) AS subscription_plan_views,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Subscription Started' AND navigation_context NOT ILIKE '%onboarding%' 
        THEN events.root_id END) AS subscriptions_started,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'View Subscription Plans' AND navigation_context NOT ILIKE '%onboarding%' 
        THEN events.master_id END) AS subscription_plan_viewers,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Subscription Started' AND navigation_context NOT ILIKE '%onboarding%' 
        THEN events.master_id END) AS subscription_starters,
       subscription_plan_views::FLOAT/NULLIF(existing_active_users, 0) AS plan_views_per_user,
       subscriptions_started::FLOAT/NULLIF(subscription_plan_views, 0) AS starts_per_plan_view,
       subscription_plan_viewers::FLOAT/NULLIF(existing_active_users, 0) AS share_active_user_seeing_buy_screen,
       subscription_starters::FLOAT/NULLIF(subscription_plan_viewers, 0) AS daily_user_buy_screen_conversion
FROM der.sp_sessions
LEFT JOIN der.events ON sp_sessions.master_id = events.master_id 
                                   AND sp_sessions.start::DATE = events.derived_tstamp::DATE
                            AND mobile_event_name IN ('View Subscription Plans', 'Subscription Started')
WHERE start >= '2022-10-01' AND start::DATE > sp_sessions.user_first_seen::DATE
GROUP BY 1, 2
ORDER BY 1, 2
;