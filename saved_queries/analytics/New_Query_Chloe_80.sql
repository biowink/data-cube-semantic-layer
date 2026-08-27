select product_tier, count(1)
from der.sessions
where session_start >= '2023-01-01'
group by 1 order by 1