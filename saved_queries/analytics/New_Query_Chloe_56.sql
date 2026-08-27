select
    day,
    network,
    sum(cost)

from import.adjust_campaign_performance
where network like '%TikTok%'
and day >= date '2025-10-01'

group by 1, 2 order by 1, 2