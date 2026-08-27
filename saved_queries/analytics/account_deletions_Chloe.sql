-- with airbyte as (
-- select date(_ab_source_file_last_modified) as dt, count(1) as deletions, 'airbyte' as source
-- from import.airbyte_account_deletions
-- where _ab_source_file_last_modified between date '2025-06-01' and date '2026-01-14'
-- group by 1 order by 1
-- ),

-- s3 as (
-- select run_date as dt, count(1) as deletions, 's3' as source
-- from import.com_helloclue_backend_events_1 
-- where event_name = 'user_deleted'
-- and run_date >= date '2026-01-14'
-- group by 1
-- order by 1
-- ),

-- tab as (
-- select * from airbyte
-- union
-- select * from s3
-- )

-- select date_trunc('week', dt), sum(deletions)
-- from tab
-- group by 1 order by 1



with s3 as (
select run_date as dt, count(1) as deletions
from import.com_helloclue_backend_events_1 
where event_name = 'user_deleted'
and run_date >= date '2026-01-14'
group by 1
order by 1
)

select avg(cast(deletions as double)) from s3



