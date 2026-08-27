WITH cycles as (
select
    analytics_id, cycle_start, cycle_end, cycle_length, ovulation_date
from der.backend_cycles
where cycle_start between date '2025-01-01' and current_date - interval '30' day
and current_cycle = false and cycle_predicted = false and cycle_excluded = false
and analytics_id is not null
limit 100
),

tracking as (
select
    analytics_id, date as tracking_date, measurement_id
from der.backend_tracking
where date >= date '2025-01-01'
and type = 'period_cramps'
),

cycles_expanded AS (
SELECT 
        cycles.analytics_id, 
        cycles.cycle_start, 
        cycles.cycle_end, 
        cycles.cycle_length, 
        cycles.ovulation_date,
        row_number.cycle_day,
        CASE WHEN cycle_day > date_diff('day', cycle_start, ovulation_date)+1 THEN TRUE ELSE FALSE END AS luteal_phase,
        CASE WHEN cycle_day > date_diff('day', cycle_start, ovulation_date)+1
             THEN cycle_day - (date_diff('day', cycle_start, ovulation_date)+1)
             ELSE cycle_day END
          AS cycle_period_day
             
    FROM cycles
    JOIN (SELECT ROW_NUMBER() OVER () AS cycle_day FROM static.calendar) AS row_number
      ON (cycle_day <= cycle_length)
),

tracked_days AS (
select 
    cycles.analytics_id,
    cycle_start,
    measurement_id,
    date_diff('day', cycle_start, tracking_date) + 1 as cycle_day,
    CASE WHEN tracking_date > ovulation_date  THEN TRUE ELSE FALSE END AS luteal_phase,
    case when tracking_date > ovulation_date
         then date_diff('day', ovulation_date, tracking_date)
         else date_diff('day', cycle_start, tracking_date) + 1
         end as cycle_period_day
from tracking
join cycles
on (cycles.analytics_id = tracking.analytics_id
    and tracking.tracking_date BETWEEN cycle_start and date_add('day', cycle_length, cycle_start)
  )
)

-- expanded AS (
    SELECT count(1)
        -- cycles_expanded.analytics_id, 
        -- cycles_expanded.cycle_start, 
        -- cycles_expanded.cycle_end, 
        -- cycles_expanded.cycle_length, 
        -- cycles_expanded.ovulation_date,
        -- cycles_expanded.cycle_day,
        -- cycles_expanded.cycle_period_day,
        -- MAX(CASE WHEN cycles_expanded.luteal_phase = tracked_days.luteal_phase AND cycles_expanded.cycle_period_day = tracked_days.cycle_period_day
        --          THEN 1 ELSE 0 END) as tracked,
        -- MIN(CASE WHEN cycles_expanded.luteal_phase = tracked_days.luteal_phase
        --          THEN ABS(cycles_expanded.cycle_period_day - tracked_days.cycle_period_day)
        --          ELSE 6 END) AS distance_to_tracked
        
    FROM cycles_expanded
    JOIN tracked_days
      ON (cycles_expanded.analytics_id = tracked_days.analytics_id
          AND cycles_expanded.cycle_start = tracked_days.cycle_start)
    -- GROUP BY 1, 2, 3, 4, 5, 6, 7
-- )

-- SELECT
--     e.*,
--     CASE 
--         WHEN e.distance_to_tracked <= 5 THEN 5 - e.distance_to_tracked
--         ELSE 0
--     END AS weighted_value
-- FROM expanded e
-- ORDER BY analytics_id, cycle_start, cycle_day