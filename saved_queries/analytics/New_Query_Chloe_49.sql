-- DROP TABLE temp.missing_cc_cycle_users;

-- create table temp.missing_cc_cycle_users (
--     analytics_id string,
--     first_start_date timestamp
-- )
-- LOCATION 's3://clue-data-prod-athena-iceberg-storage/iceberg/temp/v'
-- TBLPROPERTIES (
--   'table_type'='iceberg'
-- );

-- insert into temp.missing_cc_cycle_users (
--     analytics_id,
--     first_start_date
-- )
-- with conceive_users as (
--     select analytics_id, min(start_date) as first_start_date
--     from der.backend_mode_switchers
--     where mode = 'CONCEIVE'
--     and start_date < date '2025-07-01'
--     group by 1
-- ),

-- new_cycle_table as (
--     SELECT json_extract_scalar(event_properties, '$.userId') as user_id
--     FROM atomic_kinesis.com_helloclue_backend_events_1 
--     WHERE com_helloclue_backend_events_1.event_name = 'computed_cycles_updated'
--     group by 1
-- ),

-- needed_users as (
--     select
--         conceive_users.analytics_id,
--         conceive_users.first_start_date
--     from conceive_users
--     join import.users on (conceive_users.analytics_id = users.analytics_id)
--     left join new_cycle_table on (users.user_id = new_cycle_table.user_id)
--     where new_cycle_table.user_id is null
-- )

-- select analytics_id, first_start_date from needed_users;


with users_in_backend_cycles as (
    select analytics_id
    from der.backend_cycles 
    where (NOT cycle_predicted or current_cycle)
    group by 1
    having max(cycle_start) < date '2025-07-01'
)

select
    count(missing_cc_cycle_users.analytics_id),
    count(users_in_backend_cycles.analytics_id)

from temp.missing_cc_cycle_users
left join users_in_backend_cycles on (missing_cc_cycle_users.analytics_id = users_in_backend_cycles.analytics_id)