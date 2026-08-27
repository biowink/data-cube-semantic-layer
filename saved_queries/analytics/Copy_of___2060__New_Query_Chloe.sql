with
actuals AS (
select DATE_TRUNC('month', cycle_start) as month, count(1) as ct
from der.backend_cpt_cycles
where cycle_start between '2020-01-01' and '2023-04-01'
group by 1 order by 1
),

predictions AS (
select DATE_TRUNC('month', cycle_start) as month, count(1) as ct
from der.backend_predicted_cpt_cycles
where cycle_start between '2020-01-01' and '2023-04-01'
group by 1 order by 1
)

select 
    month,
    actuals.ct as actuals,
    predictions.ct as predictions
from actuals
join predictions using(month)
