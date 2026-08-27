select cycle_start_date, count(1) from awsdatacatalog.research.predicted_cycles
-- group by date(collector_tstamp) order by date(collector_tstamp) desc
-- limit 30;

group by 1 order by 1