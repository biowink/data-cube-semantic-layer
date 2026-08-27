WITH cycle_indexing AS (
    SELECT
        user_id,
        cycle_id,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY cycle_start)
            AS cycle_index
    FROM clean_cycles
    WHERE cycle_start >= '2014-01-01'
),

diffs as (
select 
    cycle_id,
    user_id,
    cycle_index,
    abs(cycle_length - cycle_length_expected) as abs_diff
from clean_cycles
JOIN cycle_indexing USING (user_id, cycle_id)
--where cycle_start >= '2014-01-01'
),

avgs AS (
SELECT
    cycle_index, 
    COUNT(cycle_id) as cycles,
    COUNT(distinct user_id) as users,
    AVG(abs_diff) as avg_error
    -- MEDIAN(abs_diff) as median_error
FROM diffs
where abs_diff <= 60
GROUP BY 1
),

medians AS (
SELECT
    cycle_index, 
    MEDIAN(abs_diff) as median_error
FROM diffs
where abs_diff <= 60
GROUP BY 1
)

select * 
FROM avgs
JOIN medians USING(cycle_index)
ORDER BY cycle_index

