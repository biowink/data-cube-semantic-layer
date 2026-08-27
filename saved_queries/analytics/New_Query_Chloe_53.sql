select 
 date_trunc('month', created_at), count(1), count(case when tracker_name = 'TikTok SAN' then 1 else null end),
 cast(count(case when tracker_name = 'TikTok SAN' then 1 else null end) as double) / count(1)

FROM import.airbyte_backend_adjust_trackers

where COALESCE(NULLIF(SPLIT_PART(tracker_name,'::',1),''),'unknown') = 'TikTok SAN'
-- and COALESCE(NULLIF(SPLIT_PART(tracker_name,'::',2),''),'unknown') = 'unknown'

group by 1 order by 1