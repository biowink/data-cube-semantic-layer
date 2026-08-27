select date_trunc('day', account_created_at) as dt, account_source, count(1)
from der.users
left join user_metrics.user_account_source on (users.analytics_id = user_account_source.analytics_id)
where account_created_at >= date '2025-08-01' and (account_source not in ('iOS', 'Android') OR account_source is null)
group by 1, 2
order by 1, 2