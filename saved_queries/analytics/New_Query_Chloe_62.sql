select
    date_trunc('month', account_created_at) as dt, account_source, count(1)
from der.users
left join user_metrics.user_account_source using(analytics_id)
group by 1, 2 order by 1, 2