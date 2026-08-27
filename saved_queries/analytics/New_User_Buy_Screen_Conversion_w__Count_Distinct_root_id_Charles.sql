SELECT derived_tstamp::DATE AS date,
       first_platform,
       COUNT(DISTINCT master_id) AS new_users,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'View Subscription Plans' THEN root_id END) AS subscription_plan_views,
       COUNT(DISTINCT CASE WHEN mobile_event_name = 'Subscription Started' THEN root_id END) AS subscriptions_started,
       subscription_plan_views::FLOAT/new_users AS plan_views_per_user,
       subscriptions_started::FLOAT/subscription_plan_views AS starts_per_plan_view
FROM der.events
INNER JOIN der.sp_users USING (master_id)
WHERE derived_tstamp >= '2022-10-01' AND first_seen >= '2022-10-01' AND derived_tstamp::DATE = first_seen::DATE
  AND first_platform IS NOT NULL
GROUP BY 1, 2
ORDER BY 2 DESC
;