select
    date(install_time) as dt,
    -- network,
    count(1) as total,
    count(case when campaign = 'unknown' then 1 else null end) as null_campaign

from user_metrics.adjust_attribution
where network = 'TikTok'
and install_time >= date '2026-01-01'
group by 1 order by 1