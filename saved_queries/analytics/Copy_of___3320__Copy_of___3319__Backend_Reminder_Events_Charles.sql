select date_trunc('month', created_at), reminder_type, count(1)
from der.backend_reminder_events
group by 1, 2 order by 1, 2