--select avg(abs(cycle_length_actual-cycle_length_predicted)) from(
select cycle_start_actual, count(cycle_id_actual) as actual, count(cycle_id_predicted) as predicted, predicted::float/actual as share from(

select
   distinct a.master_id
   ,a.cycle_id as cycle_id_actual
   ,p.cycle_id as cycle_id_predicted
   ,a.cycle_batch_id as cycle_batch_id_actual
   ,p.cycle_batch_id as cycle_batch_id_predicted
   ,a.cycle_start as cycle_start_actual
   ,p.cycle_start as cycle_start_predicted
   ,a.cycle_end as cycle_end_actual
   ,p.cycle_end as cycle_end_predicted
   ,a.cycle_length as cycle_length_actual
   ,p.cycle_length as cycle_length_predicted
   ,a.ovulation_date as ovulation_date_actual
   ,p.ovulation_date as ovulation_date_predicted
   ,a.backend_updated_at as backend_updated_at_actual
   ,p.backend_updated_at as backend_updated_at_predicted
   ,a.etl_execution_date as etl_execution_date_actual
   ,p.etl_execution_date as etl_execution_date_predicted
   ,a.etl_updated_at as etl_updated_at_actual
   ,p.etl_updated_at as etl_updated_at_predicted
   ,a.tracking_event_revision as tracking_event_revision_actual
   ,p.tracking_event_revision as tracking_event_revision_predicted
from
    der.backend_cpt_cycles a
left join der.backend_predicted_cpt_cycles p on a.master_id=p.master_id and a.cycle_start=p.cycle_start
where
    a.cycle_excluded is FALSE
    -- and a.cycle_predicted is FALSE
    -- and a.current_cycle is FALSE
    and a.cycle_start >= '2022-11-01'
    and a.cycle_start < '2023-04-12'
    AND cycle_start_actual <= etl_execution_date_actual
)
group by 1 order by 1