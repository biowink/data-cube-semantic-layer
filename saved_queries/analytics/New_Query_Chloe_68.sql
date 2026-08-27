select
    date_trunc('month', account_created_at) as account_creation_date,
    count(1) as users_who_signed_up_with_email,
    count(case when email_is_verified = true then 1 else null end) / cast(count(1) as double) as share_of_email_accounts_verified

from der.users
join user_metrics.user_onboarding_funnel using (analytics_id)
where did_create_account_method = 'email'
and account_created_at between date '2024-01-01' and date '2025-08-01'
group by 1 order by 1



select
    date_trunc('month', account_created_at) as account_creation_date,
    count(case when did_create_account_method = 'email' then 1 else null end) / cast(count(1) as double) as pct_users_who_registered_with_email

from der.users
join user_metrics.user_onboarding_funnel using (analytics_id)
where account_created_at between date '2024-01-01' and date '2025-08-01'
group by 1 order by 1