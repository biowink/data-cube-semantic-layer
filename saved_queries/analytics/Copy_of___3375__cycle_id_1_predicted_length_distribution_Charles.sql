select cycle_length, count(*) as count from der.backend_cpt_cycles
where cycle_predicted = true
and cycle_id = 1 and cycle_length <= 40
group by cycle_length