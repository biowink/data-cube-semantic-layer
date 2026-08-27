select 
    cycle_count,
    case when total_dates_tracked >= total_days/2.0 then true else false end as tracked_atleast_half_of_time,
    case when tracked_cramps_latest_cycle > 0 then true else false end as tracked_cramps_in_latest_cycle,
    count(1) as users_with_atleast_2_cramps_cycle,
    count(case when cycles_with_cramps = cycle_count then 1 else null end) as cramps_every_cycle
from temp.cycle_prediction_sample
join user_metrics.user_last_optional_consent_status 
on (cycle_prediction_sample.analytics_id = user_last_optional_consent_status.analytics_id)
where consent_usage_analytics = true
and cycles_with_cramps >= 2 and cycle_count >= 3
group by 1, 2, 3 order by 1, 2, 3

-- supertrackers
select analytics_id
from temp.cycle_prediction_sample
where cycle_count = 7 and cycles_with_cramps = cycle_count and total_dates_tracked >= total_days/2.0
and average_cramps_tracked_per_cycle < 20
limit 100

-- regular users
select analytics_id
from temp.cycle_prediction_sample
where cycle_count = 7 and cycles_with_cramps between 3 and 4 and tracked_cramps_latest_cycle = 1 and total_dates_tracked < total_days/2.0
and average_cramps_tracked_per_cycle < 20
limit 100

-- baby supertrackers
select analytics_id
from temp.cycle_prediction_sample
where cycle_count = 3 and cycles_with_cramps = cycle_count and total_dates_tracked >= total_days/2.0
and average_cramps_tracked_per_cycle < 20
limit 100

-- new regular users
select analytics_id
from temp.cycle_prediction_sample
where cycle_count = 3 and cycles_with_cramps > 1 and tracked_cramps_latest_cycle = 1 and total_dates_tracked < total_days/2.0
and average_cramps_tracked_per_cycle < 20
limit 100



select 
    cast(tracked_cramps_cycle_1 as varchar)
     || cast(tracked_cramps_cycle_2 as varchar)
     || cast(tracked_cramps_cycle_3 as varchar)
     || cast(tracked_cramps_cycle_4 as varchar)
     || cast(tracked_cramps_cycle_5 as varchar)
     || cast(tracked_cramps_cycle_6 as varchar) as history,
     count(1)
from temp.cycle_prediction_sample
where cycle_count = 7 and cycles_with_cramps between 3 and 4 and tracked_cramps_latest_cycle = 1 and total_dates_tracked < total_days/2.0
group by 1 order by 2 desc


select round(average_cramps_tracked_per_cycle), count(1)
from temp.cycle_prediction_sample
where cycles_with_cramps = cycle_count and total_days/cast(cycle_count as double) between 25 and 38
group by 1 order by 1