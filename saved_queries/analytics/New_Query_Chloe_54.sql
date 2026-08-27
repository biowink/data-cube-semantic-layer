select
    date_trunc('month', session_start) as month,
    count(1) as sessions,
    count(previous_session_id) as previous_session_ids
from der.sessions
group by 1 order by 1