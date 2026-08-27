with diffs as (
select 
    cycle_id,
    user_id,
    abs(cycle_length - cycle_length_expected) as abs_diff
from clean_cycles
where cycle_start >= '2014-01-01'
),

total as (
select count(cycle_id) as total
from diffs
)


select 
    abs_diff, 
    count(cycle_id) as cycles, 
    cycles::FLOAT/total as share_of_total
from diffs
join total on 1=1
where abs_diff is not null and abs_diff <= 60
group by abs_diff, total
order by abs_diff