select
    date(backend_updated_at),
    count(1)
from core.clue_users
where is_account_deleted
and backend_updated_at >= date '2026-01-01'
group by 1 order by 1