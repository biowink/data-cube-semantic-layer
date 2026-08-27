with session_cts as (
select
    master_id,
    date_trunc('day', session_start) as date,
    count(session_id) as sessions
from der.sessions
where session_start >= current_date - '30 days'::interval
group by 1, 2
),

summed as (
select 
    count(date) as total_days,
    count(distinct master_id) as total_unique_users
from session_cts
),

agg as (
select 
    case when sessions = 1 then '1 session' else '2 + sessions' end as num_sessions, 
    count(date) as days,
    count(distinct master_id) as unique_users
from session_cts
group by 1
)

select num_sessions,
days,
days::float/total_days as pct_of_total_days,
unique_users,
unique_users::float / total_unique_users as pct_of_total_unique_users
from agg
join summed on 1=1
order by 1

