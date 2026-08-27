select date_trunc('day', etl_created_at) as dt, count(session_id) as sessions
from der.sp_sessions
where etl_created_at BETWEEN '2022-02-01' and '2022-04-01'
group by 1 order by 1