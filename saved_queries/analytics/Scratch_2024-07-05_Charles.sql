SELECT *
FROM rep.active_user_trends
WHERE date = DATE('2024-06-30')
ORDER BY date DESC, platform
;

SELECT platform,
    COUNT(*) AS count_rows,
    COUNT(DISTINCT country_name) AS count_countries,
    SUM(cohort_size) AS sum_cohort_size,
    SUM(previous_month_mau) AS sum_previous_month_mau,
    SUM(retained_mau) AS sum_retained_mau,
    SUM(new_mau) AS sum_new_mau,
    SUM(reactivated_mau) AS sum_reactivated_mau,
    SUM(churned_mau) AS sum_churned_mau,
    SUM(net_mau) AS sum_net_mau,
    SUM(total_days_active) AS sum_total_days_active,
    SUM(count_view_subscription_plans_users) AS sum_count_view_subscription_plans_users,
    SUM(total_view_subscription_plans_days) AS sum_total_view_susbscription_plans_days,
    SUM(total_view_subscription_plans) AS sum_total_view_subscription_plans,
    SUM(count_subscription_started_users) AS sum_count_subscription_started_users
FROM rep.monthly_active_user_growth
WHERE month = DATE('2024-06-01')
GROUP BY 1
ORDER BY 1 DESC
LIMIT 500
;

SELECT date,
    COUNT(*),
    MAX(ranking),
    MIN(ranking)
FROM rep.keywords
GROUP BY 1
ORDER BY 1 DESC
LIMIT 500
;

SELECT *
FROM rep.ratings
LIMIT 500
;

SELECT COUNT(DISTINCT app),
       COUNT(DISTINCT platform),
       COUNT(DISTINCT country),
       COUNT(DISTINCT language),
       COUNT(DISTINCT device),
       COUNT(DISTINCT version_type),
       COUNT(DISTINCT stars)
FROM rep.ratings
;

SELECT date,
    COUNT(*),
    SUM(total_count)
FROM rep.ratings
GROUP BY 1
ORDER BY 1 DESC
LIMIT 500
;

SELECT date,
    SUM(1) AS count_rows,
    SUM(CASE WHEN is_clue_plus THEN 1 END) AS count_clue_plus,
    SUM(CASE WHEN is_paid_subscribed THEN 1 END) AS count_paid_subscribed,
    SUM(CASE WHEN date = account_created_dt THEN 1 END) AS count_new_accounts,
    SUM(CASE WHEN country_name = 'United States' THEN 1 END) AS count_us,
    SUM(CASE WHEN mode = 'Conceive' THEN 1 END) AS count_conceive
FROM der.clue_plus_user_lifetimes
GROUP BY 1
ORDER BY date desc
LIMIT 500
;

SELECT date,
    SUM(1) AS count_rows,
    SUM(CASE WHEN mode = 'conceive' THEN 1 END) AS count_conceive,
    SUM(CASE WHEN mode_previous_day = 'conceive' THEN 1 END) AS count_conceive_previous,
    SUM(CASE WHEN platform = 'android' THEN 1 END) AS count_android,
    SUM(CASE WHEN language = 'Portuguese' THEN 1 END) AS count_portuguese,
    SUM(CASE WHEN is_dau THEN 1 END) AS count_dau,
    SUM(CASE WHEN is_wau THEN 1 END) AS count_wau,
    SUM(CASE WHEN is_mau THEN 1 END) AS count_mau,
    SUM(CASE WHEN had_period THEN 1 END) AS count_period,
    SUM(CASE WHEN had_unprotected_sex THEN 1 END) AS count_unprotected_sex,
    SUM(CASE WHEN had_positive_ovulation_test THEN 1 END) AS count_pot,
    SUM(CASE WHEN had_positive_pregnancy_test THEN 1 END) AS count_ppt
FROM der.clue_plus_user_lifetimes
WHERE date >= DATE('2024-01-01')
GROUP BY 1
ORDER BY date desc
LIMIT 500
;

SELECT date,
    SUM(1) AS count_rows,
    SUM(CASE WHEN is_clue_plus THEN 1 END) AS count_clue_plus,
    SUM(CASE WHEN is_paid_subscribed THEN 1 END) AS count_paid_subscribed,
    SUM(CASE WHEN subscription_status = 'subscribed_paid' THEN 1 END) AS count_paid_status,
    SUM(CASE WHEN subscription_status_previous_day = 'subscribed_paid' THEN 1 END) AS count_paid_status_previous,
    SUM(CASE WHEN date = account_created_dt THEN 1 END) AS count_new_accounts,
    SUM(CASE WHEN country_name = 'United States' THEN 1 END) AS count_us,
    SUM(CASE WHEN mode = 'conceive' THEN 1 END) AS count_conceive,
    SUM(CASE WHEN mode_previous_day = 'conceive' THEN 1 END) AS count_conceive_previous
FROM der.clue_plus_user_lifetimes
WHERE date >= DATE('2024-01-01')
GROUP BY 1
ORDER BY date desc
LIMIT 500
;

SELECT date,
    SUM(1) AS count_rows,
    SUM(count_mode_tenure_days) AS count_mode_tenure_days,
    SUM(count_sessions) AS count_sessions,
    SUM(sum_session_length_sec) AS session_length_sec,
    SUM(sum_change_mode) AS sum_change_mode,
    SUM(sum_open_cycle_view) AS sum_open_cycle_view,
    SUM(sum_open_calendar) AS sum_open_calendar,
    SUM(sum_open_analysis) AS sum_open_analysis,
    SUM(sum_open_content_tab) AS sum_open_content_tab,
    SUM(sum_exit_data_entry) AS sum_exit_data_entry
FROM der.clue_plus_user_lifetimes
WHERE date >= DATE('2024-01-01') AND EXTRACT('day' from date) = 1
GROUP BY 1
ORDER BY date desc
LIMIT 500
;

SELECT date,
    SUM(1) AS count_rows,
    SUM(CASE WHEN is_clue_plus THEN 1 END) AS count_clue_plus,
    SUM(CASE WHEN is_paid_subscribed THEN 1 END) AS count_paid_subscribed,
    SUM(CASE WHEN subscription_status = 'subscribed_paid' THEN 1 END) AS count_paid_status,
    SUM(CASE WHEN subscription_status_previous_day = 'subscribed_paid' THEN 1 END) AS count_paid_status_previous,
    SUM(CASE WHEN date = account_created_dt THEN 1 END) AS count_new_accounts,
    SUM(CASE WHEN country_name = 'United States' THEN 1 END) AS count_us,
    SUM(CASE WHEN mode = 'conceive' THEN 1 END) AS count_conceive,
    SUM(CASE WHEN mode_previous_day = 'conceive' THEN 1 END) AS count_conceive_previous
FROM der.clue_plus_user_lifetimes
WHERE date >= DATE('2022-01-01') AND EXTRACT('day' from date) = 1
GROUP BY 1
ORDER BY date desc
LIMIT 500
;

SELECT date,
    SUM(1) AS count_rows,
    SUM(CASE WHEN mode = 'conceive' THEN 1 END) AS count_conceive,
    SUM(CASE WHEN mode_previous_day = 'conceive' THEN 1 END) AS count_conceive_previous,
    SUM(CASE WHEN platform = 'android' THEN 1 END) AS count_android,
    SUM(CASE WHEN language = 'Portuguese' THEN 1 END) AS count_portuguese,
    SUM(CASE WHEN is_dau THEN 1 END) AS count_dau,
    SUM(CASE WHEN is_wau THEN 1 END) AS count_wau,
    SUM(CASE WHEN is_mau THEN 1 END) AS count_mau,
    SUM(CASE WHEN had_period THEN 1 END) AS count_period,
    SUM(CASE WHEN had_unprotected_sex THEN 1 END) AS count_unprotected_sex,
    SUM(CASE WHEN had_positive_ovulation_test THEN 1 END) AS count_pot,
    SUM(CASE WHEN had_positive_pregnancy_test THEN 1 END) AS count_ppt
FROM der.clue_plus_user_lifetimes
WHERE date >= DATE('2022-01-01') AND EXTRACT('day' from date) = 1
GROUP BY 1
ORDER BY date desc
LIMIT 500
;

SELECT consent_usage_analytics_revoke_dt IS NOT NULL,
       COUNT(*)
FROM der.clue_plus_user_lifetimes
WHERE date = DATE('2024-07-07')
GROUP BY 1
ORDER BY 2 DESC;

SELECT COUNT(*)
FROM intermediate.clue_plus_users;

SELECT *
FROM der.subscription_history
WHERE analytics_id = 'clue-67704e551f3606513f8f57c3de768ec'
;

SELECT *
FROM intermediate.clue_plus_user_daily_subscription_status
WHERE analytics_id = 'clue-3d3d0ecee83314cb1f6c7256e59746d'
ORDER BY date
;

SELECT *
FROM import.subscriptions
WHERE id = '441ed5bb-39d5-4ef6-aaf2-a77bf3cae612'
;

SELECT *
FROM der.sessions
WHERE session_start >= DATE('2024-07-01') AND analytics_id = 'clue-2a3b68e007e7e6335f72512f601c59b'
ORDER BY session_start
;

SELECT *
FROM der.backend_tracking
WHERE date = DATE('2024-06-08') AND analytics_id = 'clue-d8ab31906885d877000606b346de17f'
AND backend_updated_at >= DATE('2024-06-01')
ORDER BY category, type
;