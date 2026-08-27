SELECT DATE_TRUNC('week', derived_tstamp::DATE) AS week,
       first_platform,
       COUNT(DISTINCT master_id) AS new_users,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'View Subscription Plans' THEN root_id END) AS subscription_plan_views,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Subscription Started' THEN root_id END) AS subscriptions_started,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'View Subscription Plans' THEN master_id END) AS subscription_plan_viewers,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Subscription Started' THEN master_id END) AS subscription_starters,
       subscription_plan_views::FLOAT/NULLIF(new_users, 0) AS plan_views_per_user,
       subscriptions_started::FLOAT/NULLIF(subscription_plan_views, 0) AS starts_per_plan_view,
       subscription_plan_viewers::FLOAT/NULLIF(new_users, 0) AS share_active_user_seeing_buy_screen,
       subscription_starters::FLOAT/NULLIF(subscription_plan_viewers, 0) AS daily_user_buy_screen_conversion
FROM der.events
INNER JOIN der.sp_users USING (master_id)
WHERE derived_tstamp >= '2022-10-01' AND first_seen >= '2022-10-01' AND DATEDIFF('hour', first_seen, derived_tstamp) <= 24 AND derived_tstamp < CURRENT_DATE 
  AND first_platform IS NOT NULL
GROUP BY 1, 2
ORDER BY 2 DESC
;