with lag_period_date as (
    select
        user_id,
        date,
        lag(date) over (partition by user_id order by date) as last_period_date
    from der.backend_tracking
    where category = 'period'
    and revision_type = 'measurements_tracked'
),

period_starts as (
    select distinct
        user_id,
        date
    from lag_period_date
    where last_period_date is null or datediff('day', last_period_date, date) > 1
      and date >= '2023-01-01'
),

tracking_sessions as (
    select
        user_id,
        date,
        MAX(CASE WHEN period_starts.date is not null then 1 else 0 end) as first_day_of_period,
        MAX(CASE WHEN category = 'period' and type = 'very_heavy' THEN 1 else 0 end) as period_very_heavy,
        MAX(CASE WHEN category = 'period' and type = 'heavy' THEN 1 else 0 end) as period_heavy,
        MAX(CASE WHEN category = 'period' and type = 'medium' THEN 1 else 0 end) as period_medium,
        MAX(CASE WHEN category = 'period' and type = 'light' THEN 1 else 0 end) as period_light,
        MAX(CASE WHEN category = 'pms' THEN 1 else 0 end) as pms,
        MAX(CASE WHEN category = 'pain' and type = 'breast_tenderness' THEN 1 else 0 end) as breast_tenderness,
        MAX(CASE WHEN category = 'pain' and type = 'headache' THEN 1 else 0 end) as headache,
        MAX(CASE WHEN category = 'pain' and type = 'lower_back' THEN 1 else 0 end) as lower_back,
        MAX(CASE WHEN category = 'pain' and type = 'period_cramps' THEN 1 else 0 end) as cramps,
        MAX(CASE WHEN category = 'pain' and type = 'migraine' THEN 1 else 0 end) as migraine
    from der.backend_tracking
    left join period_starts using(user_id, date)
    where revision_type = 'measurements_tracked'
        and date >= '2023-01-01'
    group by 1, 2
    having period_very_heavy + period_heavy + period_medium + period_light = 1
)

select
    first_day_of_period,
    period_very_heavy,
    period_heavy,
    period_medium,
    period_light,
    count(1) as tracking_sessions,
    avg(pms::float) as pms, 
    avg(breast_tenderness::float) as breast_tenderness,
    avg(headache::float) as headache,
    avg(migraine::float) as migraine,
    avg(lower_back::float) as lower_back,
    avg(cramps::float) as cramps
from tracking_sessions
group by 1, 2, 3, 4, 5
ORDER BY 1, 2, 3, 4, 5