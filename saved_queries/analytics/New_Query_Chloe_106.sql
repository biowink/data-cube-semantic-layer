with non_cumul_counts as (
    select date, app, platform, country, language, device, version_type, stars, total_count,
    total_count - lag(total_count, 1) over (partition by app, platform, country, language, device, version_type, stars 
                              order by date) as day_count
    from rep.ratings
)

select
    app, platform, country, language, device, version_type, stars,
    count(day_count) as count,
    avg(case when day_count < 0 then 1.0 else 0.0 end) as error_rate
from non_cumul_counts
where day_count is not null
group by 1, 2, 3, 4, 5, 6, 7
order by 2, 1, 3, 4, 5, 6, 7
