select * from research.cycles
where analytics_id = 'clue-d2d7f07cfa40f30b301fc8820a0d904'
  and cycle_start_date = date '2025-10-17';
  
  
  
  
select * from core.clue_users where analytics_id = 'clue-d0abca05678d5a5c2a24eae9c93ca31';




select
    date_trunc('month', collector_tstamp) as dt,
    computed_cycle_type,
    count(1) as ct
from research.predicted_cycles
group by 1, 2 order by 1, 2