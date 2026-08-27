select
    day,
    sum(cost),
    sum(installs)
from import.adjust_campaign_performance
where network = 'Apple Search Ads'
and day >= date '2025-11-20'
group by 1 order by 1