select
    date_trunc('month', install_time) as month,
    tracker_name = 'TikTok SAN' as no_campaign_level_attr,
    count(1) as users
from der.backend_adjust_trackers
where tracker_name like '%TikTok%'
 and install_time >= date '2025-10-01'
 group by 1,2 order by 1,2