WITH tracking AS (
SELECT
    tracking.master_id,
    tracking.date,
    tracking.category,
    tracking.type,
    tracking.backend_created_at as tracked_at,
    MAX(cycle_start) as most_recent_cycle_start
    
FROM (select * from der.tracking 
        where backend_created_at between '2022-01-01' and '2022-03-01'
        AND category not in ('bodily_changes', 'nursing') and category not like 'postpartum%' and category not like 'pregnancy%'
     ) as tracking
JOIN clean_cycles AS cycles ON (tracking.master_id = cycles.master_id)
  WHERE cycles.cycle_start <= tracking.date
GROUP BY 1, 2, 3, 4, 5
),

cts as (
SELECT
    CASE WHEN tracking.date between cycle_start and period_end
         THEN 'period'
         WHEN tracking.date between period_end and cycle_end - '18 days'::INTERVAL
         THEN 'follicular'
         WHEN tracking.date between cycle_end - '18 days'::INTERVAL and cycle_end - '11 days'::INTERVAL
         THEN 'fertile window'
         WHEN tracking.date between cycle_end - '11 days'::INTERVAL and cycle_end
         THEN 'luteal'
         ELSE 'other'
         END AS cycle_phase,
    category, 
    tracking.type,
    COUNT(1) as ct

FROM tracking
JOIN der.cycles ON (tracking.master_id = cycles.master_id AND tracking.most_recent_cycle_start = cycles.cycle_start)
WHERE cycle_end IS NOT NULL
  AND period_start is not null
  AND datediff('day', cycle_start, cycle_end) <= 50
  AND cycle_phase != 'other'
GROUP BY 1, 2, 3
ORDER BY 1, 4 DESC
)

select
    cycle_phase, row_number()