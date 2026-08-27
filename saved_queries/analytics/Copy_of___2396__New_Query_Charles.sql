-- select select_signup_method_ts, did_authenticate_social_account_ts, open_cycle_view_ts, *
-- from user_metrics.user_onboarding_funnel
-- where view_subscription_plans_ts IS NULL
-- and open_cycle_view_ts iS NOT NULL
-- and platform = 'ios'
-- and open_cycle_view_ts >= '2023-08-20'
-- and DATE_DIFF('day',show_welcome_screen_ts, open_cycle_view_ts) <= 0
-- limit 50;

-- select open_cycle_view_ts IS NOT NULL, Count(1)
-- from user_metrics.user_onboarding_funnel
-- where show_welcome_screen_ts IS NOT NULL
-- AND show_user_intent_screen_ts IS NULL
-- and platform = 'ios'
-- and show_welcome_screen_ts >= '2023-08-20'
-- group by 1

-- select show_welcome_screen_ts, show_user_intent_screen_ts, did_authenticate_social_account_ts, open_cycle_view_ts, *
-- from user_metrics.user_onboarding_funnel
-- where show_welcome_screen_ts IS NOT NULL
-- -- AND show_user_intent_screen_ts IS NULL
-- and platform = 'ios'
-- and show_welcome_screen_ts >= '2023-08-20'
-- limit 50

select CASE WHEN show_welcome_screen_ts IS NOT NULL THEN 'welcome screen - ' else '' end
 + CASE WHEN show_user_intent_screen_ts IS NOT NULL THEN 'show user intent - ' else ' - ' end
 + CASE WHEN did_authenticate_social_account_ts IS NOT NULL THEN 'authenticated social - ' else ' - ' end
 + CASE WHEN did_create_account_ts IS NOT NULL THEN 'created account - ' else ' - ' end
 + CASE WHEN finish_onboarding_ts IS NOT NULL THEN 'finish onboarding - ' else ' - ' end
 + CASE WHEN open_cycle_view_ts IS NOT NULL THEN 'open cycle view - ' else ' - ' end
 + CASE WHEN open_data_entry_ts IS NOT NULL THEN 'open data entry - ' else ' - ' end as funnel,
 count(1) as user_ct
from user_metrics.user_onboarding_funnel
where show_welcome_screen_ts IS NOT NULL
-- AND show_user_intent_screen_ts IS NULL
and platform = 'ios'
and show_welcome_screen_ts >= '2023-08-20'
group by 1 order by user_ct desc