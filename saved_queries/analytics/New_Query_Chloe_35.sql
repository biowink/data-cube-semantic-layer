select etl_execution_date, count(1) from archived.backend_cycles_raw
group by 1 order by 1
